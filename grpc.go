package wgephemeralpeer

import (
	"context"
	"errors"
	"time"

	"golang.zx2c4.com/wireguard/wgctrl/wgtypes"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	"github.com/mullvad/rsw-proto/ephemeralpeer"
)

var (
	ErrMissingPostQuantumResponse = errors.New("missing post quantum response")
)

func (ep *ephemeralPeer) register(publicKey, ephemeralPublicKey *wgtypes.Key) (*wgtypes.Key, error) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
	defer cancel()

	conn, err := grpc.NewClient(
		ep.apiAddress.String(),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return nil, err
	}
	defer conn.Close()

	c := ephemeralpeer.NewEphemeralPeerClient(conn)

	req := ep.getRegisterRequest(publicKey, ephemeralPublicKey)
	resp, err := c.RegisterPeerV1(ctx, req)
	if err != nil {
		return nil, err
	}

	if req.PostQuantum != nil && resp.PostQuantum == nil {
		return nil, ErrMissingPostQuantumResponse
	}

	if resp.PostQuantum != nil {
		pskBytes, err := ep.generatePSK(resp.PostQuantum.Ciphertexts)
		if err != nil {
			return nil, err
		}

		psk, err := wgtypes.NewKey(pskBytes)
		if err != nil {
			return nil, err
		}

		return &psk, nil
	}

	return nil, nil
}

func (ep *ephemeralPeer) getRegisterRequest(publicKey, ephemeralPublicKey *wgtypes.Key) *ephemeralpeer.EphemeralPeerRequestV1 {
	req := ephemeralpeer.EphemeralPeerRequestV1{
		WgParentPubkey:        publicKey[:],
		WgEphemeralPeerPubkey: ephemeralPublicKey[:],
	}

	if len(ep.kems) > 0 {
		req.PostQuantum = ep.getRegisterPQRequest()
	}

	return &req
}

func (ep *ephemeralPeer) getRegisterPQRequest() *ephemeralpeer.PostQuantumRequestV1 {
	var kp []*ephemeralpeer.KemPubkeyV1

	for _, k := range ep.kems {
		kp = append(kp, &ephemeralpeer.KemPubkeyV1{
			AlgorithmName: getAlgorithmName(k.scheme.Name()),
			KeyData:       k.publicKey,
		})
	}

	return &ephemeralpeer.PostQuantumRequestV1{KemPubkeys: kp}
}

func getAlgorithmName(name string) string {
	switch name {
	case "mceliece460896":
		return "Classic-McEliece-460896f-round3"
	default:
		return name
	}
}
