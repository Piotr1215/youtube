// Two events: one logs a duration, the other an email address.
package main

import (
	"log"
	"time"
)

type Credentials struct{ Email, Password string }

func loggedIn(creds Credentials, elapsed time.Duration) {
	log.Printf("login took %v", elapsed)
	log.Printf("user %v logged in", creds.Email)
}
