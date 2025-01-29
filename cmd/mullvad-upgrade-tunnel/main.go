package main

import (
	"context"
	"flag"
	"fmt"
	"net/netip"
	"os"
	"runtime"

	"github.com/mullvad/wgephemeralpeer"
	"github.com/mullvad/wgephemeralpeer/internal/args"
)

var VERSION string

func main() {
	iface := flag.String("wg-interface", "", "wireguard interface")
	kem := flag.String("kem", "cme-mlkem", "key encapsulation methods to use when negotiating psk")
	version := flag.Bool("version", false, "display version and exit")
	apiAddr := flag.String("api-address", wgephemeralpeer.DefaultAPIAddress.String(), "the address used to connect to the gRPC API")
	flag.Parse()

	if *version {
		fmt.Fprintf(
			os.Stdout,
			"%s version %s %s/%s\n",
			os.Args[0], VERSION, runtime.GOOS, runtime.GOARCH,
		)
		os.Exit(0)
	}

	if *iface == "" {
		fmt.Fprintf(os.Stderr, "usage: %s -wg-interface <interface>\n", os.Args[0])
		os.Exit(1)
	}

	options, err := args.ParseKem(*kem)
	if err != nil {
		fmt.Fprintf(os.Stderr, "unable to parse kem, %v\n", err)
		os.Exit(1)
	}

	ap, err := netip.ParseAddrPort(*apiAddr)
	if err != nil {
		fmt.Fprintf(os.Stderr, "unable to parse api-address, %v\n", err)
		os.Exit(1)
	}
	options = append(options, wgephemeralpeer.WithAPIAddress(ap))

	if err := wgephemeralpeer.Connect(*iface, options...); err != nil {
		if err == context.DeadlineExceeded {
			fmt.Fprintf(os.Stderr, "unable to connect to relay, ensure you are able to connect to %v over TCP\n", ap)
		} else if err == wgephemeralpeer.ErrPeerAlreadyUpgraded {
			fmt.Fprintf(os.Stderr, "unable to upgrade tunnel, %v\n", err)
		} else {
			fmt.Fprintf(os.Stderr, "unable to connect ephemeral peer, %v\n", err)
		}
		os.Exit(1)
	}
}
