package args

import (
	"fmt"

	ep "github.com/mullvad/wgephemeralpeer"
)

func ParseKem(kem string) ([]ep.Option, error) {
	var k []ep.Option

	switch kem {
	case "cme":
		k = append(k, ep.WithMcEliece460896Round3())
	case "kyber":
		k = append(k, ep.WithKyber1024())
	case "cme-kyber":
		k = append(k, ep.WithMcEliece460896Round3())
		k = append(k, ep.WithKyber1024())
	case "kyber-cme":
		k = append(k, ep.WithKyber1024())
		k = append(k, ep.WithMcEliece460896Round3())
	case "mlkem":
		k = append(k, ep.WithMLKEM1024())
	case "cme-mlkem":
		k = append(k, ep.WithMcEliece460896Round3())
		k = append(k, ep.WithMLKEM1024())
	case "mlkem-cme":
		k = append(k, ep.WithMLKEM1024())
		k = append(k, ep.WithMcEliece460896Round3())
	default:
		return nil, fmt.Errorf("invalid kem identifier: %s", kem)
	}

	return k, nil
}
