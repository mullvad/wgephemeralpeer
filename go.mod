module github.com/mullvad/wgephemeralpeer

// Use go 1.19 to ensure the application can be built on an OpenWrt device.
// Bump once a newer package is available at:
// https://openwrt.org/packages/pkgdata/golang
go 1.19

replace github.com/cloudflare/circl => github.com/mullvad/circl v0.0.0-20240104174227-83b264e1de1f

require (
	github.com/cloudflare/circl v1.3.7
	golang.zx2c4.com/wireguard/wgctrl v0.0.0-20230429144221-925a1e7659e6
	google.golang.org/grpc v1.63.2
	google.golang.org/grpc/cmd/protoc-gen-go-grpc v1.3.0
	google.golang.org/protobuf v1.33.0
)

require (
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/josharian/native v1.1.0 // indirect
	github.com/mdlayher/genetlink v1.3.2 // indirect
	github.com/mdlayher/netlink v1.7.2 // indirect
	github.com/mdlayher/socket v0.5.1 // indirect
	golang.org/x/crypto v0.22.0 // indirect
	golang.org/x/net v0.24.0 // indirect
	golang.org/x/sync v0.7.0 // indirect
	golang.org/x/sys v0.19.0 // indirect
	golang.org/x/text v0.14.0 // indirect
	golang.zx2c4.com/wireguard v0.0.0-20231211153847-12269c276173 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20240415180920-8c6c420018be // indirect
)
