package wgephemeralpeer

import (
	"errors"
	"net/netip"

	"github.com/cloudflare/circl/kem"
	"golang.zx2c4.com/wireguard/wgctrl/wgtypes"
)

var (
	ErrMissingKEMs    = errors.New("missing KEMs")
	DefaultAPIAddress = netip.AddrPortFrom(
		netip.AddrFrom4([4]byte{10, 64, 0, 1}), 1337)
)

type ephemeralPeer struct {
	daita      bool
	kemSchemes []kem.Scheme
	kems       []pqkem
	apiAddress netip.AddrPort
}

func newEP(opts ...Option) (*ephemeralPeer, error) {
	ep := &ephemeralPeer{apiAddress: DefaultAPIAddress}

	for _, opt := range opts {
		opt(ep)
	}

	if len(ep.kemSchemes) == 0 {
		return nil, ErrMissingKEMs
	}

	if err := ep.initPQ(); err != nil {
		return nil, err
	}

	return ep, nil
}

// Connect accepts a WireGuard interface name and a set of options and attempts
// to establish an ephemeral peer by using the information that is configured
// on the device. This function requires root privileges to work.
func Connect(iface string, opts ...Option) error {
	ep, err := newEP(opts...)
	if err != nil {
		return err
	}

	// Get the public key of the private key that is configured on the
	// WireGuard device.
	publicKey, err := ep.getPublicKey(iface)
	if err != nil {
		return err
	}

	// Generate new ephemeral peer private and public WireGuard keys.
	ephemeralPrivateKey, err := wgtypes.GeneratePrivateKey()
	if err != nil {
		return err
	}
	ephemeralPublicKey := ephemeralPrivateKey.PublicKey()

	// Register the ephemeral peer on the Mullvad relay. A PSK will be
	// returned if that is desired.
	psk, err := ep.register(publicKey, &ephemeralPublicKey)
	if err != nil {
		return err
	}

	// Update the WireGuard device with the ephemeral private key and PSK.
	return ep.updateConfiguration(iface, &ephemeralPrivateKey, psk)
}

// Register takes the public key, ephemeral public key and a set of options and
// submits them to the gRPC API which registers the ephemeral peer as a child
// of the public key. If a PSK is requested it will be returned.
func Register(publicKey, ephemeralPublicKey *wgtypes.Key, opts ...Option) (*wgtypes.Key, error) {
	ep, err := newEP(opts...)
	if err != nil {
		return nil, err
	}

	return ep.register(publicKey, ephemeralPublicKey)
}
