use Mix.Config

config :nerves_io_ethernet,
       os_module: Nerves.IO.Ethernet.Test.Mocks.OS

config :logger, :console,
       level: :info
