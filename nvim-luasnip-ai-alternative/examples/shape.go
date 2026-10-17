// Three calls with one shape, each needing a different change.
package main

import (
	"log"
	"net/http"
	"time"
)

func serve(r *http.Request, addr string, backoff time.Duration) {
	log.Printf("got here %v", r.URL)
	log.Printf("listening on %s", addr)
	log.Printf("retrying in %v", backoff)
}
