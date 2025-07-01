package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestNewService(t *testing.T) {
	service := NewService("test-service", "test-path", "test-kubeconfig", "test-context")

	if service.Name != "test-service" {
		t.Errorf("expected Name to be 'test-service', got '%s'", service.Name)
	}
	if service.Path != "test-path" {
		t.Errorf("expected Path to be 'test-path', got '%s'", service.Path)
	}
	if service.KubeConfig != "test-kubeconfig" {
		t.Errorf("expected KubeConfig to be 'test-kubeconfig', got '%s'", service.KubeConfig)
	}
	if service.Context != "test-context" {
		t.Errorf("expected Context to be 'test-context', got '%s'", service.Context)
	}
}

func TestCreateDirectory(t *testing.T) {
	service := NewService("test-service", "test-path", "", "")
	defer os.RemoveAll("test-path")

	err := service.CreateDirectory()
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}

	if _, err := os.Stat(filepath.Join("test-path", "test-service")); os.IsNotExist(err) {
		t.Errorf("expected directory to exist, but it does not")
	}
}

func TestCreateTerraformFiles(t *testing.T) {
	service := NewService("test-service", "test-path", "", "")
	defer os.RemoveAll("test-path")

	err := service.CreateDirectory()
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}

	err = service.CreateTerraformFiles()
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}

	for _, file := range service.getTerraformFiles() {
		if _, err := os.Stat(file.path); os.IsNotExist(err) {
			t.Errorf("expected file '%s' to exist, but it does not", file.path)
		}
	}
}

func TestInitializeTerraform(t *testing.T) {
	service := NewService("test-service", "test-path", "", "")
	defer os.RemoveAll("test-path")

	err := service.CreateDirectory()
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}

	err = service.InitializeTerraform()
	if err != nil {
		t.Errorf("expected no error, got '%v'", err)
	}
}
