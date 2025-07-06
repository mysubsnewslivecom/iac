package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"strings"

	vault "github.com/hashicorp/vault/api"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/schollz/progressbar/v3"
	"github.com/spf13/cobra"
)

func main() {
	setupLogger()

	var verbose bool
	var quiet bool

	rootCmd := &cobra.Command{
		Use:   "vaultcli",
		Short: "Vault CLI tool to manage Vault initialization, unseal, and setup",
		PersistentPreRun: func(cmd *cobra.Command, args []string) {
			if quiet {
				zerolog.SetGlobalLevel(zerolog.Disabled)
			} else if verbose {
				zerolog.SetGlobalLevel(zerolog.DebugLevel)
			} else {
				zerolog.SetGlobalLevel(zerolog.InfoLevel)
			}
		},
	}

	rootCmd.PersistentFlags().String("config", "", "Config file (JSON/YAML)")
	rootCmd.PersistentFlags().String("vault-addr", "", "Vault address")
	rootCmd.PersistentFlags().String("vault-secret", "", "Vault token file path")
	rootCmd.PersistentFlags().String("vault-user", "", "Userpass username")
	rootCmd.PersistentFlags().String("vault-pass", "", "Userpass password")
	rootCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "Verbose output")
	rootCmd.PersistentFlags().BoolVarP(&quiet, "quiet", "q", false, "Quiet mode")

	rootCmd.AddCommand(initCmd())
	rootCmd.AddCommand(unsealCmd())
	rootCmd.AddCommand(setupCmd())

	if err := rootCmd.Execute(); err != nil {
		log.Fatal().Err(err).Msg("Command failed")
	}
}

func initCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "init",
		Aliases: []string{"i"},
		Short:   "Initialize Vault and output unseal keys and root token",
		Long: `Initialize Vault and output unseal keys and root token.

Examples:
  vaultcli init
  vaultcli i --vault-addr http://vault.example.com:8200`,
		Run: func(cmd *cobra.Command, args []string) {
			cfg, err := initConfig(cmd)
			if err != nil {
				log.Error().Err(err).Msg("Configuration error")
				os.Exit(1)
			}

			client, err := vault.NewClient(&vault.Config{Address: cfg.VaultAddr})
			if err != nil {
				log.Error().Err(err).Msg("Failed to create Vault client")
				os.Exit(1)
			}

			ctx := context.Background()
			bar := progressbar.NewOptions(1,
				progressbar.OptionSetDescription("Initializing Vault"),
				progressbar.OptionShowCount(),
				progressbar.OptionClearOnFinish(),
			)

			resp, err := client.Sys().InitWithContext(ctx, &vault.InitRequest{
				SecretShares:    5,
				SecretThreshold: 3,
			})
			if err != nil {
				log.Error().Err(err).Msg("Vault init error")
				os.Exit(1)
			}
			bar.Add(1)

			fmt.Println()
			fmt.Printf("\033[32mVault initialized successfully!\033[0m\n") // green
			fmt.Printf("Root Token:\n  \033[33m%s\033[0m\n", resp.RootToken) // yellow
			fmt.Println("Unseal Keys:")
			for i, key := range resp.Keys {
				fmt.Printf("  Key %d: \033[33m%s\033[0m\n", i+1, key)
			}
		},
	}
}

func unsealCmd() *cobra.Command {
	var keys []string

	cmd := &cobra.Command{
		Use:     "unseal",
		Aliases: []string{"u"},
		Short:   "Unseal Vault using unseal keys",
		Long: `Unseal Vault by providing one or more unseal keys.

If no keys are provided via --key flags, you will be prompted to enter them interactively.

Examples:
  vaultcli unseal --key <key1> --key <key2> --key <key3>
  vaultcli u`,
		Run: func(cmd *cobra.Command, args []string) {
			cfg, err := initConfig(cmd)
			if err != nil {
				log.Error().Err(err).Msg("Configuration error")
				os.Exit(1)
			}

			// Prompt interactively if no keys provided
			if len(keys) == 0 {
				fmt.Println("No unseal keys provided via flags.")
				keys = promptUnsealKeys()
			}

			manager, err := NewVaultManager(cfg)
			if err != nil {
				log.Error().Err(err).Msg("Failed to create Vault manager")
				os.Exit(1)
			}

			if err := manager.UnsealVault(keys); err != nil {
				log.Error().Err(err).Msg("Unseal failed")
				os.Exit(1)
			}
			fmt.Println("\033[32mVault unsealed successfully!\033[0m") // green
		},
	}

	cmd.Flags().StringSliceVar(&keys, "key", []string{}, "Unseal key (multiple allowed)")

	return cmd
}

func promptUnsealKeys() []string {
	fmt.Println("Enter unseal keys (one per line). Submit empty line to finish:")
	scanner := bufio.NewScanner(os.Stdin)
	var keys []string
	for {
		fmt.Printf("Key %d: ", len(keys)+1)
		if !scanner.Scan() {
			break
		}
		key := strings.TrimSpace(scanner.Text())
		if key == "" {
			break
		}
		keys = append(keys, key)
	}
	return keys
}

func setupCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "setup",
		Aliases: []string{"s"},
		Short:   "Setup Vault policies, auth methods, userpass user, and KV secrets engine",
		Long: `Setup Vault with default policies, enable userpass and kubernetes auth methods, create user, and enable KV secrets engine.

Examples:
  vaultcli setup
  vaultcli s --vault-user airflow --vault-pass mypass`,
		Run: func(cmd *cobra.Command, args []string) {
			cfg, err := initConfig(cmd)
			if err != nil {
				log.Error().Err(err).Msg("Configuration error")
				os.Exit(1)
			}

			manager, err := NewVaultManager(cfg)
			if err != nil {
				log.Error().Err(err).Msg("Failed to create Vault manager")
				os.Exit(1)
			}

			if err := manager.SetupVault(); err != nil {
				log.Error().Err(err).Msg("Vault setup failed")
				os.Exit(1)
			}

			fmt.Println("\033[32mVault setup completed successfully!\033[0m") // green
		},
	}
}

type VaultManager struct {
	cfg    *Config
	client *vault.Client
	ctx    context.Context
}

func NewVaultManager(cfg *Config) (*VaultManager, error) {
	client, err := vault.NewClient(&vault.Config{
		Address: cfg.VaultAddr,
	})
	if err != nil {
		return nil, err
	}

	if cfg.SecretPath != "" {
		token, err := os.ReadFile(cfg.SecretPath)
		if err != nil {
			return nil, fmt.Errorf("failed to read vault token file: %w", err)
		}
		client.SetToken(strings.TrimSpace(string(token)))
	}

	return &VaultManager{
		cfg:    cfg,
		client: client,
		ctx:    context.Background(),
	}, nil
}

func (v *VaultManager) InitVault() (*vault.InitResponse, error) {
	bar := progressbar.Default(1, "Initializing Vault")
	resp, err := v.client.Sys().InitWithContext(v.ctx, &vault.InitRequest{
		SecretShares:    5,
		SecretThreshold: 3,
	})
	bar.Finish()

	if err != nil {
		return nil, fmt.Errorf("vault init failed: %w", err)
	}

	log.Info().Msg("Vault initialized")
	return resp, nil
}

func (v *VaultManager) UnsealVault(keys []string) error {
	sealStatus, err := v.client.Sys().SealStatusWithContext(v.ctx)
	if err != nil {
		return fmt.Errorf("failed to check seal status: %w", err)
	}

	if !sealStatus.Sealed {
		log.Info().Msg("Vault is already unsealed")
		return nil
	}

	bar := progressbar.Default(int64(len(keys)), "Unsealing Vault")
	for _, key := range keys {
		if key == "" {
			continue
		}
		resp, err := v.client.Sys().UnsealWithContext(v.ctx, key)
		if err != nil {
			return fmt.Errorf("unseal error: %w", err)
		}
		bar.Add(1)
		if !resp.Sealed {
			log.Info().Msg("Vault unsealed successfully")
			return nil
		}
	}
	bar.Finish()
	return fmt.Errorf("vault still sealed after provided keys")
}

func (v *VaultManager) SetupVault() error {
	log.Info().Msg("Applying Vault configuration...")

	if err := v.createPolicies(); err != nil {
		return fmt.Errorf("failed to create policies: %w", err)
	}
	if err := v.enableAuthMethods(); err != nil {
		return fmt.Errorf("failed to enable auth methods: %w", err)
	}
	if err := v.createUser(); err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}
	if err := v.enableSecretsEngine(); err != nil {
		return fmt.Errorf("failed to enable secrets engine: %w", err)
	}

	return nil
}

func (v *VaultManager) createPolicies() error {
	readWritePolicy := `
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/metadata/*" {
  capabilities = ["list"]
}`

	adminPolicy := `
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}`

	log.Info().Msg("Creating policies...")

	if err := v.client.Sys().PutPolicyWithContext(v.ctx, "read-write", readWritePolicy); err != nil {
		return err
	}
	if err := v.client.Sys().PutPolicyWithContext(v.ctx, "admin", adminPolicy); err != nil {
		return err
	}
	return nil
}

func (v *VaultManager) enableAuthMethods() error {
	auths, err := v.client.Sys().ListAuthWithContext(v.ctx)
	if err != nil {
		return err
	}

	if _, ok := auths["userpass/"]; !ok {
		log.Info().Msg("Enabling userpass auth...")
		if err := v.client.Sys().EnableAuthWithOptions("userpass", &vault.EnableAuthOptions{Type: "userpass"}); err != nil {
			return err
		}
	}

	if _, ok := auths["kubernetes/"]; !ok {
		log.Info().Msg("Enabling kubernetes auth...")
		if err := v.client.Sys().EnableAuthWithOptions("kubernetes", &vault.EnableAuthOptions{Type: "kubernetes"}); err != nil {
			return err
		}
	}

	return nil
}

func (v *VaultManager) createUser() error {
	log.Info().Str("user", v.cfg.UserName).Msg("Creating userpass user...")

	data := map[string]interface{}{
		"password": v.cfg.UserPass,
		"policies": "read-write",
	}

	path := fmt.Sprintf("auth/userpass/users/%s", v.cfg.UserName)
	if _, err := v.client.Logical().WriteWithContext(v.ctx, path, data); err != nil {
		return err
	}
	return nil
}

func (v *VaultManager) enableSecretsEngine() error {
	mounts, err := v.client.Sys().ListMountsWithContext(v.ctx)
	if err != nil {
		return err
	}

	if _, ok := mounts["secret/"]; !ok {
		log.Info().Msg("Mounting KV v2 at secret/")
		err := v.client.Sys().Mount("secret", &vault.MountInput{
			Type:    "kv",
			Options: map[string]string{"version": "2"},
		})
		if err != nil {
			return err
		}
	}

	return nil
}
