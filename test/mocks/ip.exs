alias Nerves.IO.Ethernet
alias Ethernet.Test
alias Test.Mocks

defmodule Mocks.IP do

  @moduledoc false

  def init(interface) do
    interface
    |> table
    |> :ets.new([:named_table, :public])
  end

  def flush(interface) do
    interface
    |> table
    |> :ets.delete_all_objects
  end

  def settings(interface) do
    interface
    |> table
    |> :ets.tab2list
    |> Enum.into(%{})
  end

  def ip <<"link set ", rest ::binary>> do
    [b_interface, updn] = String.split(rest)
    b_interface
    |> table
    |> :ets.insert(updn: updn)
    "ok"
  end

  def ip <<"addr flush dev ", b_interface :: binary>> do
    b_interface
    |> flush
    "ok"
  end

  def ip <<"addr add ", rest :: binary>> do
    [ipandmask, "dev", b_interface] = String.split(rest)
    [ip, mask] = String.split(ipandmask, "/")
    b_interface
    |> table
    |> :ets.insert(ip: ip, mask: mask)
    "ok"
  end

  def ip <<"route add default via ", rest :: binary>> do
    [router, "dev", b_interface] = String.split(rest)
    b_interface
    |> table
    |> :ets.insert(router: router)
    "ok"
  end

  defp table(interface), do: (:"mocks_ip_#{interface}")

end
