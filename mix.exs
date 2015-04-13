defmodule Ethernet.Mixfile do

  use Mix.Project

  def project, do: [
     app: :ethernet,
     version: "0.1.0",
     elixir: "~> 1.0",
     deps: deps
  ]

  def application, do: [applications: [:logger]]

  defp deps, do: [
    {:persistent_storage, github: "cellulose/persistent_storage"}
  ]

end
