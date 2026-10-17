// The same failed login, logged by log.Printf and by slog.
package main

import (
	"errors"
	"log"
	"log/slog"
)

func main() {
	err := errors.New("no password")
	log.Printf("login failed: %v", err)
	slog.Error("login failed", "err", err)
}
