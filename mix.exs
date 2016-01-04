defmodule Nerves.IO.Ethernet.Mixfile do

  @version "0.5.0-pre"

  use Mix.Project

  def project, do: [
    app: :nerves_io_ethernet,
    version: @version,
    elixir: "~> 1.0",
    deps: deps,
    description: "Nerves Ethernet IO Module",
    # Hex
    package: package,
    # ExDoc
    name: "Nerves.IO.Ethernet",
    docs: [source_ref: "v#{@version}",
           main: "Nerves.IO.Ethernet",
           source_url: "https://github.com/nerves-project/nerves_io_ethernet"]
  ]

  def application, do: [
    applications: [:logger],
    mod: {Nerves.IO.Ethernet, []}
  ]

  defp deps, do: [
    {:earmark, "~> 0.1", only: [:dev, :docs]},
    {:ex_doc, "~> 0.8", only: [:dev, :docs]}
  ]

  defp package, do: [
    maintainers: ["Garth Hitchens", "Chris Dutton"],
    licenses: ["MIT"],
    links: %{github: "https://github.com/nerves-project/nerves_io_ethernet"},
    files: ~w(lib config) ++
           ~w(README.md CHANGELOG.md LICENSE mix.exs)
  ]

end
