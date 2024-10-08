package wgephemeralpeer

import (
	"testing"

	"github.com/cloudflare/circl/kem/kyber/kyber1024"
	"github.com/cloudflare/circl/kem/mceliece/mceliece460896"
	"github.com/cloudflare/circl/kem/mlkem/mlkem1024"
)

func TestCirclStringIdsAreUnchanged(t *testing.T) {
	// This is required because we're embedding KEM string identifiers
	// in the request that gets sent to the server.
	// If identifiers in CIRCL were to change, requests would start failing
	// inexplicably and everyone would be scratching their heads.
	if mceliece460896.Scheme().Name() != "mceliece460896" {
		t.Fatal("Identifier for CME has changed")
	}
	if kyber1024.Scheme().Name() != "Kyber1024" {
		t.Fatal("Identifier for Kyber has changed")
	}
	if mlkem1024.Scheme().Name() != "ML-KEM-1024" {
		t.Fatal("Identifier for ML-KEM has changed")
	}
}
