alias Nerves.Networking
alias Networking.Test
alias Test.Mocks

defmodule Mocks.OS do

  @moduledoc false

  def cmd <<"/sbin/ip ", rest :: binary >> do
    Mocks.IP.ip(rest)
  end

  def cmd <<"udhcpc ", rest :: binary>> do
    Mocks.UDHCPC.udhcpc(rest)
  end

  def cmd(command) when is_list(command) do
    command
    |> :erlang.list_to_binary
    |> cmd
    |> :erlang.binary_to_list
  end

end
