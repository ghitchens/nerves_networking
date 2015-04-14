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

    ifname        - The ethernet interface (defaults to "eth0")
    hostname      - Hostname to pass during a DHCP request (defaults to "cell")
    static_config - Statically set the interface configuration
        Required params for static_config:
        ip       - IP address to configure to (e.g. "192.168.15.100")
        mask     - Subnet Mask to use (e.g. "255.255.255.0")
        router   - IP address of router (e.g. "192.168.15.1")

## Static IP Configuration Storage

Ethernet is capable of storing static configuration provided a module is
implemented following the `Ethernet.Storage` Behaviour. It is up to the implementer to determine how this should be accomplished. An example of using
`cellulose/persistent_storage` is provided in the `/examples` directory.

To utilize your module just specify it in your config:

    config :ethernet, storage: EthernetPersistentStorage

Or when you start Ethernet just pass it with the key `:storage`:

    Ethernet.start storage: EthernetPersistentStorage

## Callbacks

```
on_change   fn/1    Called with an ENUM representing the changes that are
                    being made

```

## Examples

    # Start Ethernet using dhcp and calling back to AIPA/ipv4ll

    #config.exs
    config :ethernet, ifname: "eth2", hostname: "bbb"

    # starting...
    iex> Ethernet.start

    # Start Ethernet with static configuration

    #config.exs
    config :ethernet, ifname: "eth2", hostname: "bbb", static_config: [
      ip: "192.168.1.100", mask: "255.255.255.0", router: "192.168.1.1"
    ]

    # starting...
    iex> Ethernet.start

## Contributing

We appreciate any contribution to Cellulose Projects, so check out our [CONTRIBUTING.md](CONTRIBUTING.md) guide for more information. We usually keep a list of features and bugs [in the issue tracker][https://github.com/cellulose/ethernet/issues].
