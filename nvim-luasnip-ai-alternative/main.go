package main

import (
	"fmt"
	"strings"
)

func main() {
	println("hallo world")
	if _, err := fmt.Printf("afunc(\"piotr\"): %v\n", afunc("piotr")); err != nil {
		return 
	}
	
}

func afunc(param1 string) string {
	return strings.ToUpper(param1)
}
