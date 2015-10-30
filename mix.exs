defmodule NervesEthernet.Mixfile do

  use Mix.Project

  def project, do: [
    app: :nerves_io_ethernet,
    version: version,
    elixir: "~> 1.0",
    deps: deps,
    name: "Nerves.Ethernet",
    description: "Ethernet support (dhcp, static, ipv4ll)",
    package: package,
    docs: [source_ref: "v#{version}", main: "Nerves.Ethernet",
           source_url: "https://github.com/nerves-project/nerves_io_ethernet"]
  ]

  def application, do: [applications: [:logger]]

  defp deps, do: [
    {:earmark, "~> 0.1", only: :docs},
    {:ex_doc, "~> 0.8", only: :docs}
  ]

  defp package, do: [
    maintainers: ["Garth Hitchens", "Chris Dutton"],
    licenses: ["MIT"],
    links: %{github: "https://github.com/nerves-project/nerves_ethernet"},
    files: ~w(lib config) ++
           ~w(README.md CHANGELOG.md LICENSE mix.exs package.json)
  ]

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
end
