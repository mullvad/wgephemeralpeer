# wgephemeralpeer

**Note for OpenWrt users: For building directly on the device, do a checkout of the revision tagged with `v1.0.4`.**

This repository contains a library that can be used to negotiate ephemeral
peers in the realm of Mullvad.

Additionally, there is a small utility called `mullvad-upgrade-tunnel`,
designed to be used in conjunction with `wg-quick` for establishing
post-quantum-secure WireGuard tunnels.

## Installation instructions

1. Download the appropriate release of `mullvad-upgrade-tunnel` tool from
   `https://github.com/mullvad/wgephemeralpeer/releases`. Alternatively, to
   build from source, see the following section.
2. Go to `https://mullvad.net/en/account/wireguard-config` and download a
   WireGuard configuration file.
3. Open the configuration file and locate the `[Interface]` section. Add
   `PostUp = mullvad-upgrade-tunnel -wg-interface %i` at the end of the
   section.

Your configuration file should now look something like this:

```
[Interface]
# Device: Mellow Merlin
PrivateKey = <redacted>
Address = 10.64.37.199/32,fc00:bbbb:bbbb:bb01::1:25c6/128
DNS = 10.64.0.1
PostUp = mullvad-upgrade-tunnel -wg-interface %i

[Peer]
PublicKey = 5JMPeO7gXIbR5CnUa/NPNK4L5GqUnreF0/Bozai4pl4=
AllowedIPs = 0.0.0.0/0,::0/0
Endpoint = 185.213.154.66:51820
```

You can now use `wg-quick` to start and stop your tunnel as usual by running
`wg-quick up <config>` and `wg-quick down <config>` respectively.

When executing `wg`, you should be able to see a `preshared key: (hidden)`
line underneath the peer section, indicating that a PSK has been successfully
configured for your tunnel.

### Build from source

To build from source, run `make` in the repository. Note that the result may
depend on the go-version you have installed. If podman is installed you can
also use the release targets to build in a container.

### macOS

The WireGuard client available in the App Store unfortunately does not support
`PostUp`. If you would like to use `mullvad-upgrade-tunnel`, you can instead
install WireGuard with [Homebrew](https://brew.sh/) and follow the
configuration instructions provided from above.

### Windows

`PostUp` is disabled by default in Windows. To enable `PostUp`, you need to
modify the registry using the following command `reg add HKLM\Software\WireGuard /v DangerousScriptExecution /t REG_DWORD /d 1 /f`.

For more information, you can refer to [this link](https://git.zx2c4.com/wireguard-windows/about/docs/adminregistry.md).

In Windows, the `%i` parameter is referred to as `%WIREGUARD_TUNNEL_NAME%`. Therefore,
the command should be updated as follows:

`PostUp = mullvad-upgrade-tunnel -wg-interface %WIREGUARD_TUNNEL_NAME%`

### SaveConfig

`wg-quick` offers a `SaveConfig` option. If set to `true`, the configuration
is saved from the current state of the interface upon shutdown. However,
please note that this option cannot be used in conjunction with
`mullvad-upgrade-tunnel`. When negotiating a PSK, you will use an ephemeral
peer that is only temporarily valid and accepted on the VPN relay. Thus, using
`SaveConfig` will replace your regular configuration with the ephemeral peer,
and subsequent attempts to establish a tunnel will fail.

## Key Encapsulation Methods

By setting the `-kem <kem>` flag, you can use one of the following key
encapsulation methods when negotiating the preshared key. The default value is
`cme-mlkem`.

- cme (Classic McEliece 460896 Round3)
- mlkem (ML-KEM-1024)
- cme-mlkem (Classic McEliece 460896 Round3 + ML-KEM-1024)
- mlkem-cme (ML-KEM-1024 + Classic McEliece 460896 Round3)

Obsolete methods that are still supported:

- cme-kyber (Classic McEliece 460896 Round3 + Kyber1024)
- kyber (Kyber1024)
- kyber-cme (Kyber1024 + Classic McEliece 460896 Round3)
