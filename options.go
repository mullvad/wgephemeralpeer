package wgephemeralpeer

import "net/netip"

type Option func(*ephemeralPeer)

// WithMcEliece460896Round3 uses the key encapsulation method
// McEliece460896-Round3 when negotiating a PSK for the ephemeral peer
func WithMcEliece460896Round3() Option {
	return func(ep *ephemeralPeer) {
		ep.kemSchemes = append(ep.kemSchemes, schemeMcEliece460896Round3)
	}
}

// WithKyber1024 uses the key encapsulation method Kyber1024 when negotiating a
// PSK for the ephemeral peer
func WithKyber1024() Option {
	return func(ep *ephemeralPeer) {
		ep.kemSchemes = append(ep.kemSchemes, schemeKyber1024)
	}
}

// WithMLKEM1024 uses the key encapsulation method ML-KEM-1024 when negotiating a
// PSK for the ephemeral peer
func WithMLKEM1024() Option {
	return func(ep *ephemeralPeer) {
		ep.kemSchemes = append(ep.kemSchemes, schemeMLKEM1024)
	}
}

// WithDAITA enables DAITA on the ephemeral peer. DAITA hides patterns in the
// VPN tunnel by generating dummy traffic and using a fixed packet size.
// However, this is not supported in vanilla WireGuard so enabling this option
// has no effect. This feature requires the Mullvad VPN app to work.
func WithDAITA(enabled bool) Option {
	return func(ep *ephemeralPeer) {
		ep.daita = enabled
	}
}

// WithAPIAddress sets the address used to connect to the gRPC API.
func WithAPIAddress(apiAddress netip.AddrPort) Option {
	return func(ep *ephemeralPeer) {
		ep.apiAddress = apiAddress
	}
}
