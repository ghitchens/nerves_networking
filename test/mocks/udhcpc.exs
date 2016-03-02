alias Nerves.IO.Ethernet
alias Ethernet.Test
alias Test.Mocks

defmodule Mocks.UDHCPC do

  @moduledoc false
  @default_params %{status: "error", lease: "", ip: "", mask: "", domain: "",
                    subnet: "", router: "", dns1: "", dns2: "", lease: ""}
  require Logger
  
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

  def setup(interface, params) when is_map(params) do
    setup(interface, Map.to_list params)
  end

  def setup(interface, params) when is_list(params) do
    interface
    |> table
    |> :ets.insert(params)
  end

  # makes the assumption we have an interfacename and hostname passed
  def udhcpc <<"-n -q -f -s /tmp/udhcpc.sh ", args :: binary>> do
    [[_, interface]] = Regex.scan ~r/--interface=(\w+) /r,args
    [[_, hostname]] = Regex.scan ~r/-H (\w*+)/r,args
    exec_udhcpc(interface, hostname)
  end

  defp table(interface), do: (:"mocks_udhcpc_#{interface}")

  defp exec_udhcpc(interface, hostname) do
    Logger.debug "udhcpc #{inspect interface} hostanme: #{inspect hostname}"
    dhcp_response interface, settings(interface)
  end

  defp dhcp_response(interface, params) do
    p = Dict.merge Map.new, params
    Logger.debug "dhcp response for #{inspect interface} -> #{inspect p}"

  """
  udhcpc (v1.23.1) started
  [
  status='deconfig'
  BINDIR='/usr/lib/erlang/erts-6.4/bin'
  EMU='beam'
  HOME='/root'
  IFS='   
  '
  LANG='en_US.UTF-8'
  LANGUAGE='en'
  PATH='/usr/lib/erlang/erts-6.4/bin:/srv/erlang/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  PPID='8360'
  PROGNAME='erl'
  PS1='# '
  PS2='> '
  PS4='+ '
  PWD='/srv/erlang'
  ROOTDIR='/srv/erlang'
  TERM='vt100'
  interface='#{interface}'
  ]
  Sending discover...
  Sending select for #{p.ip}...
  Lease of #{p.ip} obtained, lease time #{p.lease}
  [
  status='#{p.status}'
  BINDIR='/usr/lib/erlang/erts-6.4/bin'
  EMU='beam'
  HOME='/root'
  IFS='   
  '
  LANG='en_US.UTF-8'
  LANGUAGE='en'
  PATH='/usr/lib/erlang/erts-6.4/bin:/srv/erlang/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  PPID='8360'
  PROGNAME='erl'
  PS1='# '
  PS2='> '
  PS4='+ '
  PWD='/srv/erlang'
  ROOTDIR='/srv/erlang'
  TERM='vt100'
  dns='#{p.dns1} #{p.dns2}'
  domain='#{p.domain}'
  interface='#{interface}'
  ip='#{p.ip}'
  lease='#{p.lease}'
  mask='#{p.mask}'
  opt53='05'
  router='#{p.router}'
  serverid='#{p.router}'
  siaddr='#{p.router}'
  subnet='#{p.subnet}'
  ]
  """
  end
end
