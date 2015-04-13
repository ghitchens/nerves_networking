Ethernet
========

Manages ethernet on [Nerves](http://nerves-project.org) based embedded systems, with optional [Celluose](http://cellulose.io) integration.

### Features

* DHCP, including timeouts and re-acquisition
* IP4LL/AIPA automatic ethernet address configuration
* Easy callback-based notification of device state changes

### Usage

```elixir
{:ok, eth0} = Ethernet.start_link interface: "eth0", hostname: "happy"
```

Options are specified by a keyword list, as follows:


keyword    | type       | description
---------- |:---------- |:-----------
interface  | string     | interface to configure (eg "eth0", "en2", "lo0", etc)
hostname   | string     | hostname to pass to dhcp server during dhcp request

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

### Areas For Improvement
- needs a lot better AIPA/IP4LL address negotiation

### Contributing

We appreciate any contribution to Cellulose Projects, so check out our [CONTRIBUTING.md](CONTRIBUTING.md) guide for more information. We usually keep a list of features and bugs [in the issue tracker][https://github.com/cellulose/ethernet/issues].
