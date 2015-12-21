defmodule Nerves.IO.Ethernet.Mixfile do

  use Mix.Project

  def project, do: [
    app: :nerves_io_ethernet,
    version: "0.4.1-pre",
    elixir: "~> 1.0",
    deps: deps,
    description: "Ethernet support for the Nerves Framework",
    # Hex
    package: package,
    # ExDoc
    name: "Nerves.IO.Ethernet",
    docs: [source_ref: "v#{version}",
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

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
  
end
