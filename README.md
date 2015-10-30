Ethernet
========

# NOT READY YET!

A [Nerves](http://nerves-project.org) module to handle ethernet on embedded
systems.

### Features

* DHCP, including timeouts and re-acquisition
* Static configuration
* IP4LL/AIPA automatic ethernet address configuration
* Easy callback-based notification of device state changes

### Usage - NOT READY YET

Include `:nerves_io_ethernet` as an application in your mix.exs.

To configure and use an adapter, simply do:

```elixir
alias Nerves.IO.Ethernet

{:ok, _pid} = Ethernet.setup :eth0
```

You can setup static IP parameters by doing something more like this:

```elixir
alias Nerves.IO.Ethernet
{:ok, _pid} = Ethernet.setup :eth0, mode: "static", ip: "10.0.0.5", router:
            "10.0.0.1", mask: "16", subnet: "255.255.0.0", mode: "static"
```

## WORK LIST

Some of the things currently on the TO-DO list before this is considered finsished:

- [ ] Rewrite this README
- [ ] Finish documentation for callback models
- [ ] Finish documentation for modes (:dynamic, :static)
- [ ] Tests for APIA/IP4LL currently fail and are disabled (bad test)
- [ ] UDP Configuration module made of broken-out parts
- [ ] Configuration storage module made of broken-out parts

