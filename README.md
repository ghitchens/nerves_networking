Ethernet
========

# NOT READY YET!

A [Nerves](http://nerves-project.org) module to handle ethernet on embedded systems.

### Features

* DHCP, including timeouts and re-acquisition
* IP4LL/AIPA automatic ethernet address configuration
* Easy callback-based notification of device state changes

### Usage

```elixir
alias Nerves.IO.Ethernet
{:ok, eth0} = Ethernet.start_link interface: "eth0", hostname: "happy"
```

Options are specified by a keyword list, as follows:

keyword   | type       | description
----------|:---------- |:-----------
interface | string     | interface to configure (eg "eth0", "en2", "lo0", etc)
hostname  | string     | hostname to pass to dhcp server during dhcp request

Config options may be specified by a keyword list for configuration in a `config.exs` file using the `:static_config` key.  Required keys of list are:

keyword   | type       | description
----------|:---------- |:-----------
ip        | string     | IP address to configure to (e.g. "192.168.15.100")
mask      | string     | Subnet Mask to use (e.g. "255.255.255.0")
router    | string     | IP address of router (e.g. "192.168.15.1")

```elixir
config :nerves_io_ethernet, static_config: [
    ip: "192.168.1.10",
    mask: "255.255.0.0",
    router: "192.168.1.1"
    ]
```

### Notifications

`Ethernet` implements an _event manager_ which provides information about changes in the status of the interface.

For instance, imagine you wanted to implement a handler that wrote the new network configuration to standard output everytime it changed.   You could implement it like this:

```elixir
defmodule NetworkStateInspectionHandler
  use GenEvent
  def handle_event(:if_changed, new_config) do
    IO.write "New configuration: #{inspect new_config}"
  end
end
```

And then, you could start the interface and add the handler like this..

```elixir
{:ok, eth0} = Ethernet.start_link interface: "eth0", hostname: "happy"
GenEvent.add_handler(eth0, NetworkStateInspectionHandler, [])
```

## Static IP Configuration Storage

`Ethernet` is capable of storing static configuration values, provided a
module is implemented following the `Ethernet.Storage` Behaviour. It is up
to the implementer to determine how this should be accomplished. An example
of using `cellulose/persistent_storage` project is provided in the `/examples`
directory.

To utilize your module just specify it in your config:

```elixir
config :nerves_io_ethernet, storage: EthernetPersistentStorage
```

Or when you start Ethernet just pass it with the key `:storage`:

```elixir
Ethernet.start storage: EthernetPersistentStorage
```

### Areas For Improvement
- needs a lot better AIPA/IP4LL address negotiation

## Examples
 
```elixir
    # Start Ethernet using dhcp and calling back to AIPA/ipv4ll

    #config.exs
    config :nerves_io_ethernet, interface: "eth2", hostname: "bbb"

    # starting...
    iex> Ethernet.start

    # Start Ethernet with static configuration

    #config.exs
    config :nerves_io_ethernet, interface: "eth2", hostname: "bbb", static_config: [
      ip: "192.168.1.100", mask: "255.255.255.0", router: "192.168.1.1"
    ]

    # starting...
    iex> Ethernet.start
```

