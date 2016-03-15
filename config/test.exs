use Mix.Config

config :nerves_networking,
       os_module: Nerves.Networking.Test.Mocks.OS

config :logger, :console,
       level: :info
