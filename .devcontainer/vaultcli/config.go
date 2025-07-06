package main

import (
	"fmt"
	"os"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type Config struct {
	VaultAddr  string `mapstructure:"vault_addr"`
	SecretPath string `mapstructure:"vault_secret"`
	UserName   string `mapstructure:"vault_user"`
	UserPass   string `mapstructure:"vault_pass"`
}

func setupLogger() {
	log.Logger = log.Output(zerolog.ConsoleWriter{
		Out:        os.Stderr,
		TimeFormat: "15:04:05",
		NoColor:    false,
	})
	zerolog.TimeFieldFormat = "15:04:05"
}

func initConfig(cmd *cobra.Command) (*Config, error) {
	v := viper.New()
	if err := v.BindPFlags(cmd.Flags()); err != nil {
		return nil, err
	}
	v.AutomaticEnv()

	configFile, _ := cmd.Flags().GetString("config")
	if configFile != "" {
		v.SetConfigFile(configFile)
		if err := v.ReadInConfig(); err != nil {
			return nil, fmt.Errorf("failed to read config file: %w", err)
		}
		log.Info().Str("file", v.ConfigFileUsed()).Msg("Loaded config file")
	}

	v.SetDefault("vault_addr", "http://127.0.0.1:8200")
	v.SetDefault("vault_secret", "vault.json")
	v.SetDefault("vault_user", "airflow")
	v.SetDefault("vault_pass", "secret1234")

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("unable to parse config: %w", err)
	}

	return &cfg, nil
}
