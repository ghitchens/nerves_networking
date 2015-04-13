Ethernet
========

Ethernet is an Actor that manages the configuration of an ethernet port.

By default, Ethernet attempts to configure an ethernet port by using
DHCP, reverting to static configuration if that fails.  It can also
be used to statically configure a port upon request.

Ethernet is implemented as a GenServer.

## Support for AIPA / ipv4ll addressing

If an IP address cannot be obtained, Ethernet automatically configures an address on the 169.254.0.0/16 network.  Microsoft calls this AIPA, and the IETF
calls it ipv4ll (ipv4 link local) addressing.

Once a node has an ipv4ll address, it broadcasts a DHCP DISCOVER packet on a
regular basis to see if a DHCP server re-appears.  The time of this
rebroadcast is progressive (see ip4ll_dhcp_retry_time).   It also retries if
it gets an SSDP notification from a client on another network.

## Configuration parameters (sent as Elixir map)

    ifname    - The ethernet interface (defaults to "eth0")
    hostname  - hostname to pass during a DHCP request (defaults to none)

ip, subnet, mask, router, dns - for static configuration

## Callbacks

```
on_change   fn/1    Called with an ENUM representing the changes that are
                    being made

```

## Contributing

We appreciate any contribution to Cellulose Projects, so check out our [CONTRIBUTING.md](CONTRIBUTING.md) guide for more information. We usually keep a list of features and bugs [in the issue tracker][https://github.com/cellulose/ethernet/issues].
