Ethernet
========

A [Nerves](http://nerves-project.org) module to handle ethernet adapter and address configuration on embedded systems.

### Features

* Supports multiple address setting modes:
    * DHCP (via `udhcpc`), including handling timeouts and re-acquisition
    * Static Address configuration
    * IP4LL/AIPA automatic ethernet address configuration
* Easy callback-based notification of device state changes

### Setup

Include `:nerves_io_ethernet` as a dependency and application in your mix.exs.

```elixir

# add as an application to start
def application, do: [
  ...
  applications: [:nerves_io_ethernet],
  ...
]

# add to your dependencies
def deps do
  [.....
  {:nerves_io_ethernet, github: "nerves-project/nerves_io_ethernet"},
  ....]
end
```

### Simple DHCP configuration

```elixir
alias Nerves.IO.Ethernet

{:ok, _pid} = Ethernet.setup :eth0
```

For a simple example, see the [Hello Network](https://github.com/nerves-project/nerves-examples/tree/master/hello_network) example.

### Static IP configuration

You can setup static IP parameters by doing something more like this:

```elixir
alias Nerves.IO.Ethernet
{:ok, _pid} = Ethernet.setup :eth0, mode: "static", ip: "10.0.0.5", router:
            "10.0.0.1", mask: "16", subnet: "255.255.0.0", mode: "static",
            dns: "8.8.8.8 8.8.4.4"
```

## WORK LIST

Some of the things currently on the TO-DO list before this is considered finsished:

- [ ] Finish documentation for callback models
- [ ] Finish documentation for modes (:dynamic, :static)
- [ ] Tests for APIA/IP4LL currently fail and are disabled (bad test)
- [ ] UDP Configuration module made of broken-out parts
- [ ] Configuration storage module made of broken-out parts
