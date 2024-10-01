package wgephemeralpeer

import (
	"errors"

	"github.com/cloudflare/circl/kem"
	"github.com/cloudflare/circl/kem/kyber/kyber1024"
	"github.com/cloudflare/circl/kem/mceliece/mceliece460896"
	"github.com/cloudflare/circl/kem/mlkem/mlkem1024"
)

var (
	ErrInvalidCiphertextsCount = errors.New("invalid ciphertexts count")
)

var (
	schemeMcEliece460896Round3 kem.Scheme = mceliece460896.Scheme()
	schemeKyber1024            kem.Scheme = kyber1024.Scheme()
	schemeMLKEM1024            kem.Scheme = mlkem1024.Scheme()
)

type pqkem struct {
	scheme     kem.Scheme
	privateKey []byte
	publicKey  []byte
}

func (ep *ephemeralPeer) initPQ() error {
	for _, s := range ep.kemSchemes {
		publicKey, privateKey, err := s.GenerateKeyPair()
		if err != nil {
			return err
		}

		k := pqkem{scheme: s}
		k.privateKey, _ = privateKey.MarshalBinary()
		k.publicKey, _ = publicKey.MarshalBinary()
		ep.kems = append(ep.kems, k)
	}

	return nil
}

func (ep *ephemeralPeer) generatePSK(ciphertexts [][]byte) ([]byte, error) {
	if len(ciphertexts) != len(ep.kems) {
		return nil, ErrInvalidCiphertextsCount
	}

	var psk []byte
	for i, k := range ep.kems {
		ct := ciphertexts[i]

		csk, err := k.scheme.UnmarshalBinaryPrivateKey(k.privateKey)
		if err != nil {
			return nil, err
		}

		s, err := k.scheme.Decapsulate(csk, ct)
		if err != nil {
			return nil, err
		}

		if psk == nil {
			psk = make([]byte, len(s))
		}

		for j, v := range s {
			psk[j] ^= v
		}
	}

	return psk, nil
}
