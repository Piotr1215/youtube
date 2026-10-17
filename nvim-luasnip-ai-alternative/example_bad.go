package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

// Example of inconsistent error handling patterns
func processUser(id string) (*User, error) {
	// Pattern 1: Bare return
	user, err := fetchUser(id)
	if err != nil {
		return nil, err
	}

	// Pattern 2: Basic error with fmt
	_, err = json.Marshal(user)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal user: %v", err)
	}

	// Pattern 3: Ignored error
	notify(user)
	record(user)
	// Pattern 4: Panic on error
	file, err := os.Open("config.json")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	// Pattern 5: Log and continue
	_, err = updateCache(user)
	if err != nil {
		fmt.Println("cache update failed:", err)
	}

	return user, nil
}

func fetchUser(id string) (*User, error) {
	resp, err := http.Get("https://api.example.com/users/" + id)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("bad status: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var user User
	err = json.Unmarshal(body, &user)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

func connectDB() (*sql.DB, error) {
	db, err := sql.Open("postgres", "connection-string")
	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		return nil, err
	}

	return db, nil
}

type User struct {
	ID    string
	Name  string
	Email string
}

// notify sends the user a push notification; failed deliveries are dropped.
func notify(user *User) error {
	// Implementation
	return nil
}

func updateCache(user *User) (bool, error) {
	// Implementation
	return true, nil
}

// record writes the user to the billing ledger that the invoice run reads.
func record(user *User) error {
	// Implementation
	return nil
}

func loadUser(id string) (*User, error) {
	user, err := fetchUser(id)
	if err != nil {
		return nil, fmt.Errorf("fetch user: %w", err)
	}
	return user, nil
}

func deleteUser(id string) error {
	req, err := http.NewRequest(http.MethodDelete, "https://api.example.com/users/"+id, nil)
	if err != nil {
		return fmt.Errorf("fetch user: %w", err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("delete user: %w", err)
	}
	return resp.Body.Close()
}