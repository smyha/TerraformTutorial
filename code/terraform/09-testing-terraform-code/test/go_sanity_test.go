package test

import (
	"fmt"
	"testing"
)

// TestGoIsWorking is a smoke test that confirms the Go toolchain and the
// Terratest scaffold are wired up correctly. We do this before running the
// longer, infrastructure-heavy tests so failures are easier to diagnose.
func TestGoIsWorking(t *testing.T) {
	fmt.Println()
	fmt.Println("If you see this text, it's working!")
	fmt.Println()
}
