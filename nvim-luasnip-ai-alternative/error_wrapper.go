package main

import "fmt"

// Simple error wrapper for demo
// In real projects, use github.com/pkg/errors or similar

type wrappedError struct {
	msg string
	err error
}

func (w wrappedError) Error() string {
	return fmt.Sprintf("%s: %v", w.msg, w.err)
}

func (w wrappedError) Unwrap() error {
	return w.err
}

// Package-specific error wrapping functions
var (
	main = struct {
		Wrap  func(error, string) error
		Wrapf func(error, string, ...interface{}) error
		Errorf func(string, ...interface{}) error
	}{
		Wrap: func(err error, msg string) error {
			if err == nil {
				return nil
			}
			return wrappedError{msg: msg, err: err}
		},
		Wrapf: func(err error, format string, args ...interface{}) error {
			if err == nil {
				return nil
			}
			return wrappedError{msg: fmt.Sprintf(format, args...), err: err}
		},
		Errorf: func(format string, args ...interface{}) error {
			return fmt.Errorf(format, args...)
		},
	}
)