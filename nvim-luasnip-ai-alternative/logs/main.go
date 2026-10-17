package main

import (
	"errors"
	"log"
	"net/http"
	"time"
)

type Credentials struct {
	Email    string
	Password string
}

func main() {
	addr := ":8080"
	http.HandleFunc("/login", login)
	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Printf("server stopped: %v", err)
	}
}

func login(w http.ResponseWriter, r *http.Request) {
	creds := Credentials{Email: r.FormValue("email"), Password: r.FormValue("password")}
	log.Printf("login request: %+v", creds)
	log.Printf("got here %v", r.URL)
	start := time.Now()
	if err := authenticate(creds); err != nil {
		log.Printf("login failed: %v", err)
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	elapsed := time.Since(start)
	log.Printf("login took %v", elapsed)
	log.Printf("user %v logged in", creds.Email)
}

func authenticate(c Credentials) error {
	backoff := 100 * time.Millisecond
	for attempt := 0; attempt < 3; attempt++ {
		if c.Password != "" {
			return nil
		}
		log.Printf("retrying in %v", backoff)
		time.Sleep(backoff)
		backoff *= 2
	}
	return errors.New("no password")
}
