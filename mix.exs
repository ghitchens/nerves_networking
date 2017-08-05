defmodule Nerves.Networking.Mixfile do

  @version "0.6.0"

  use Mix.Project

  def project, do: [
    app: :nerves_networking,
    version: @version,
    elixir: "~> 1.0",
    deps: deps(),
    description: "Nerves Networking Module",
    # Hex
    package: package(),
    # ExDoc
    name: "Nerves.Networking",
    docs: [source_ref: "v#{@version}",
           main: "Nerves.Networking",
           source_url: "https://github.com/nerves-project/nerves_networking"]
  ]

  def application, do: [
    applications: [:logger, :crypto],
    mod: {Nerves.Networking, []}
  ]

  defp deps, do: [
    {:earmark, "~> 0.1", only: [:dev, :docs]},
    {:ex_doc, "~> 0.8", only: [:dev, :docs]}
  ]

  defp package, do: [
    maintainers: ["Garth Hitchens", "Chris Dutton"],
    licenses: ["MIT"],
    links: %{github: "https://github.com/nerves-project/nerves_networking"},
    files: ~w(lib config) ++
           ~w(README.md CHANGELOG.md LICENSE mix.exs)
  ]

end
