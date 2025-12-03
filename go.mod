module github.com/mullvad/wgephemeralpeer

go 1.24.11

replace github.com/cloudflare/circl => github.com/mullvad/circl v0.0.0-20240930082155-0c072461a157

require (
	github.com/cloudflare/circl v1.3.7
	github.com/mullvad/rsw-proto/ephemeralpeer v0.0.0-20250129161004-22e2b2ff31b3
	golang.zx2c4.com/wireguard/wgctrl v0.0.0-20241231184526-a9ab2273dd10
	google.golang.org/grpc v1.70.0
)

require (
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/josharian/native v1.1.0 // indirect
	github.com/mdlayher/genetlink v1.3.2 // indirect
	github.com/mdlayher/netlink v1.7.2 // indirect
	github.com/mdlayher/socket v0.5.1 // indirect
	golang.org/x/crypto v0.32.0 // indirect
	golang.org/x/net v0.34.0 // indirect
	golang.org/x/sync v0.10.0 // indirect
	golang.org/x/sys v0.29.0 // indirect
	golang.org/x/text v0.21.0 // indirect
	golang.zx2c4.com/wireguard v0.0.0-20231211153847-12269c276173 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20250127172529-29210b9bc287 // indirect
	google.golang.org/protobuf v1.36.4 // indirect
)
