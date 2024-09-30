package wgephemeralpeer

import (
	"errors"
	"os"

	"golang.zx2c4.com/wireguard/wgctrl"
	"golang.zx2c4.com/wireguard/wgctrl/wgtypes"
)

var (
	ErrDeviceDoesNotExist   = errors.New("device does not exist")
	ErrInvalidNumberOfPeers = errors.New("invalid number of peers")
	ErrPeerAlreadyUpgraded  = errors.New("peer has already been upgraded")
)

func (ep *ephemeralPeer) getPublicKey(iface string) (*wgtypes.Key, error) {
	client, err := wgctrl.New()
	if err != nil {
		return nil, err
	}
	defer client.Close()

	device, err := client.Device(iface)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, ErrDeviceDoesNotExist
		}
		return nil, err
	}

	var zeroKey wgtypes.Key
	for _, p := range device.Peers {
		if p.PresharedKey != zeroKey {
			return nil, ErrPeerAlreadyUpgraded
		}
	}

	publicKey := device.PrivateKey.PublicKey()
	return &publicKey, nil
}

func (ep *ephemeralPeer) updateConfiguration(iface string, ephemeralPrivateKey, psk *wgtypes.Key) error {
	client, err := wgctrl.New()
	if err != nil {
		return err
	}
	defer client.Close()

	device, err := client.Device(iface)
	if err != nil {
		if os.IsNotExist(err) {
			return ErrDeviceDoesNotExist
		}
		return err
	}

	if len(device.Peers) != 1 {
		return ErrInvalidNumberOfPeers
	}

	peer := wgtypes.PeerConfig{
		AllowedIPs:                  device.Peers[0].AllowedIPs,
		Endpoint:                    device.Peers[0].Endpoint,
		PersistentKeepaliveInterval: &device.Peers[0].PersistentKeepaliveInterval,
		PublicKey:                   device.Peers[0].PublicKey,
	}

	if psk != nil {
		peer.PresharedKey = psk
	}

	cfg := wgtypes.Config{
		FirewallMark: &device.FirewallMark,
		ListenPort:   &device.ListenPort,
		Peers:        []wgtypes.PeerConfig{peer},
		PrivateKey:   ephemeralPrivateKey,
	}

	return client.ConfigureDevice(iface, cfg)
}
