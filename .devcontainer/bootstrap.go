package main

import (
	"flag"
	"fmt"
	"os"
	"sync"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"os/exec"
	"path/filepath"
)

const (
	defaultKubeConfigPath = "~/.kube/config"
	defaultConfigContext  = "docker-desktop"
	defaultChartName      = "nginx"
	defaultChartVersion   = "13.0.0"
	defaultChartRepo      = "https://charts.bitnami.com/bitnami"
	defaultPath           = "helms"
)

var FILES = map[string]string{
	"backend":   "backend.tf",
	"providers": "providers.tf",
	"terraform": "terraform.tf",
	"variables": "variables.tf",
	"main":      "main.tf",
	"tfvars":    "terraform.tfvars",
}

var once sync.Once

func init() {
	once.Do(func() {
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
		if os.Getenv("DEBUG") != "" {
			zerolog.SetGlobalLevel(zerolog.DebugLevel)
		}
		log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: zerolog.TimeFormatUnix})
	})
}

// Service represents a service with its configuration.
type Service struct {
	Name       string
	Path       string
	KubeConfig string
	Context    string
}

// NewService creates a new Service instance.
func NewService(name, path, kubeConfig, context string) *Service {
	return &Service{
		Name:       name,
		Path:       path,
		KubeConfig: kubeConfig,
		Context:    context,
	}
}

// CreateDirectory creates the directory for the service.
func (s *Service) CreateDirectory() error {
	return os.MkdirAll(filepath.Join(s.Path, s.Name), 0755)
}

// CreateTerraformFiles creates necessary Terraform files.
func (s *Service) CreateTerraformFiles() error {
	files := s.getTerraformFiles()
	for _, file := range files {
		log.Info().Str("file", file.path).Msg("Creating file")
		err := createFile(file.path, file.content)
		if err != nil {
			log.Error().Err(err).Str("file", file.path).Msg("Error creating file")
			return err
		}
	}
	return nil
}

func (s *Service) getTerraformFiles() []fileInfo {
	return []fileInfo{
		{
			path:    filepath.Join(s.Path, s.Name, FILES["backend"]),
			content: s.getBackendContent(),
		},
		{
			path:    filepath.Join(s.Path, s.Name, FILES["providers"]),
			content: s.getProvidersContent(),
		},
		{
			path:    filepath.Join(s.Path, s.Name, FILES["terraform"]),
			content: s.getTerraformContent(),
		},
		{
			path:    filepath.Join(s.Path, s.Name, FILES["variables"]),
			content: s.getVariablesContent(),
		},
		{
			path:    filepath.Join(s.Path, s.Name, FILES["main"]),
			content: s.getMainContent(),
		},
		{
			path:    filepath.Join(s.Path, s.Name, FILES["tfvars"]),
			content: s.getTfvarsContent(),
		},
	}
}

type fileInfo struct {
	path    string
	content string
}

func (s *Service) getBackendContent() string {
	return `terraform {
  backend "local" {
    path = "statefile/terraform.tfstate"
  }
}`
}

func (s *Service) getProvidersContent() string {
	return fmt.Sprintf(`provider "helm" {
  debug = true
  kubernetes {
    config_path    = var.kubeconfig
    config_context = var.config_context
  }
}`)
}

func (s *Service) getTerraformContent() string {
	return `terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}`
}

func (s *Service) getVariablesContent() string {
	return fmt.Sprintf(`variable "kubeconfig" {
  type        = string
  default     = "%s"
}

variable "config_context" {
  type        = string
  default     = "%s"
}

variable "namespace" {
  type        = string
  description = "Namespace"
}

variable "release_name" {
  type        = string
  description = "application name"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.release_name))
    error_message = "Chart name must consist of alphanumeric characters and hyphens."
  }
}

variable "chart_name" {
  type        = string
  description = "Name of the Helm chart to be deployed"
  default     = "%s"
}

variable "repository_url" {
  type        = string
  description = "URL of the Helm chart repository"
  default     = "%s"
}

variable "chart_version" {
  type        = string
  description = "Version of the Helm chart to be deployed"
  default     = "%s"
}`, s.KubeConfig, s.Context, defaultChartName, defaultChartRepo, defaultChartVersion)
}

func (s *Service) getMainContent() string {
	return fmt.Sprintf(`resource "helm_release" "%s" {
  name             = var.release_name
  repository       = var.repository_url
  chart            = var.chart_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  upgrade_install  = true
  values           = []
}`, s.Name)
}

func (s *Service) getTfvarsContent() string {
	return fmt.Sprintf(`release_name   = "%s"
kubeconfig     = "%s"
config_context = "%s"
namespace      = "%s"
repository_url = "%s"
chart_name     = "%s"
chart_version  = ""`, s.Name, s.KubeConfig, s.Context, s.Name, defaultChartRepo, s.Name)
}

// InitializeTerraform initializes Terraform in the service directory.
func (s *Service) InitializeTerraform() error {
	initCmd := fmt.Sprintf("terraform -chdir=%s init", filepath.Join(s.Path, s.Name))
	return executeCommand(initCmd)
}

func main() {
	serviceName := flag.String("service", "", "Service name (required)")
	path := flag.String("path", defaultPath, "Path name")
	flag.Parse()

	if *serviceName == "" {
		log.Error().Msg("Usage: go run main.go -service <service-name> -path <path>")
		os.Exit(1)
	}

	service := NewService(*serviceName, *path, defaultKubeConfigPath, defaultConfigContext)

	err := service.CreateDirectory()
	if err != nil {
		log.Error().Err(err).Msg("Error creating directory")
		os.Exit(1)
	}

	err = service.CreateTerraformFiles()
	if err != nil {
		log.Error().Err(err).Msg("Error creating Terraform files")
		os.Exit(1)
	}

	err = service.InitializeTerraform()
	if err != nil {
		log.Error().Err(err).Msg("Error initializing Terraform")
		os.Exit(1)
	}
}

func createFile(filePath, content string) error {
	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = file.WriteString(content)
	if err != nil {
		return err
	}
	return nil
}

func executeCommand(command string) error {
	cmd := exec.Command("sh", "-c", command)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
