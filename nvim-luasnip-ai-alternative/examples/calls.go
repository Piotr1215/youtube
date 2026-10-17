// Calls a text search gets wrong: one split over two lines, one commented out.
package main

import (
	"errors"
	"log"
)

func main() {
	err := errors.New("no password")
	name := "ana"
	log.Printf("login failed: %v", err)
	log.Printf(
		"server stopped: %v", err)
	// log.Printf("failed: %v", err)
	log.Printf("user %v", name)
}
