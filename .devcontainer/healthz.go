package main

import (
	"flag"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// log zerolog.Logger
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

func main() {
	service := flag.String("s", "", "Service name (required)")
	flag.Parse()

	if *service == "" {
		log.Error().Msg("Usage: ./healthz -s <service-name>")
		os.Exit(1)
	}

	// Service URL to check
	serviceURL := *service

	// Timeout for the health check
	timeout := 1 * time.Minute

	// Interval between retries
	retryInterval := 10 * time.Second
	startTime := time.Now()
	log.Info().Str("service", serviceURL).Msg("Checking if the service is up...")

	for {
		// Send HTTP GET request
		resp, err := http.Get(serviceURL)
		if err == nil && resp.StatusCode == http.StatusOK {
			log.Info().Msg("Service is up and running!")
			return
		}

		// Check if timeout has been reached
		if time.Since(startTime) > timeout {
			log.Error().Msg("Timeout reached. Service is not responding.")
			return
		}

		log.Info().Msg("Service not ready yet. Retrying...")
		time.Sleep(retryInterval)
	}
}
