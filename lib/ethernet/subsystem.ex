defmodule Nerves.IO.Ethernet.Subsystem do

  @moduledoc """
  Implements an ethernet subsystem based on using the `ip` and `udhcpc` CLI.
  Designed for embedded systems to provide simple ipv4 ethernet access.

  This doesn't rely on using `udhcpc` as a daemon, but instead simply invokes
  it to perform low level configuration, assuming the
  `Nerves.IO.Ethernet` module handles daemon-level functionality like
  DHCP renewal, etc.

  Major Limitations:
  - does not yet support ipv6
  - horrible error checking for low level commands (assumes they work)
  """

  require Logger

  @type reason :: any
  @type ip_address :: String.t
  @type interface :: String.t

  @udhcpc_script_path "/tmp/udhcpc.sh"
  @resolv_conf_path (case Mix.env do
    :test -> "/tmp/resolv.conf"
    _ -> "/etc/resolv.conf"
  end)
  @default_hostname "nerves"

  @useful_dhcp_keys  [
    :status, :interface, :ip, :subnet, :mask, :timezone, :router,
    :timesvr, :dns, :hostname, :domain, :ipttl, :broadcast, :ntpsrv,
    :opt53, :lease, :dhcptype, :serverid, :message
  ]

  @doc "Initialize the ethernet subsystem"
  @spec initialize() :: :ok | {:error, reason}
  def initialize do
    Logger.debug "initializing Ethernet Subsystem"
    ensure_udhcpc_setup!
    :ok
  end

  @doc "Set the link state of an interface up or down"
  @spec link_set(interface, :up | :down) :: :ok
  def link_set(interface, :up) do
    ip_cmd "link set #{interface} up"
  end

  def link_set(interface, :down) do
    ip_cmd "link set #{interface} down"
  end

  @doc "Return the MAC address of the specified interface"
  @spec mac_address(interface) :: String.t
  def mac_address(interface) do
    File.read! "/sys/class/net/#{interface}/address"
  end

  @doc "add an address to the interface"
  def add_address(interface, ip, mask) do
    ip_cmd "addr add #{ip}/#{mask} dev #{interface}"
  end

  @doc "clear the list of addresses for the interface"
  @spec flush_addresses(interface) :: :ok
  def flush_addresses(interface) do
    ip_cmd "addr flush dev #{interface}"
  end

  @doc "set the router (default gateway) for the inteface"
  @spec set_router(interface, ip_address) :: :ok
  def set_router(interface, router) do
    ip_cmd "route add default via #{router} dev #{interface}"
  end

  @doc "set resolver configuration"
  @spec set_resolv_conf(String.t, String.t) :: :ok
  def set_resolv_conf(dns, domain \\ nil) do
    resolv_conf = resolv_domain(domain) <> resolv_dns(dns) <> "\n"
    Logger.debug "setting resolver config: #{resolv_conf}"
    File.write! @resolv_conf_path, resolv_conf
    :ok
  end

  # given a string like "4.4.4.4 8.8.8.8", return resolv.conf lines with newlines
  def resolv_dns(dns) do
    dns
    |> String.split(" ")
    |> Enum.map(&("nameserver #{&1}"))
    |> Enum.join("\n")
  end

  # given a domain return the resolver domain line with newline
  defp resolv_domain(domain) do
    case domain do
      "" -> ""
      nil -> ""
      d -> "domain #{d}\n"
    end
  end

  @doc """
  Makes a dhcp request on the specified interface with optional hostname, and
  returns `Dict` with standardized keys for the result of the DHCP request.

  Uses `udhcpc` in non-daemon mode to handle dhcp.
  """
  @spec dhcp_request(interface, String.t) :: Dict.t
  def dhcp_request(interface, host) do
    "udhcpc -n -q -f -s #{@udhcpc_script_path} --interface=#{interface} -x hostname: #{hostname(host)}"
    |> os_cmd
    |> parse_udhcpc_response
    |> filter_to_only_useful_dhcp_keys
  end

  # convert the response from udhcpc to Dict form by walking through resulting
  # responses to select the last (most relelvant) response, and convert to Dict
  # form
  defp parse_udhcpc_response(response) do
    case (Regex.scan ~r/\[.*\]/sr, response) do
      [_, [last_response]] ->
        Regex.scan(~r/(\w+='.+')\n/r, last_response)
        |> Enum.map(&cleanup_kv/1)
      _ ->
        Logger.error "#{__MODULE__} udhcpc invalid response: #{response}" 
        []
    end
  end

  # respond only with keys that are useful for dhcp
  defp filter_to_only_useful_dhcp_keys(dict) do
    Enum.filter(dict, fn({k,_v}) -> Enum.member?(@useful_dhcp_keys, k) end)
  end

  # transform "foo='bar'" to {:foo, "bar"} to parse udhcpc result
  defp cleanup_kv([_, kqval]) do
    [key, qval] = String.split(kqval, "=")
    [_, val] = Regex.run(~r/'(.+)'/s, qval)
    {String.to_atom(key), val}
  end

  # write a script for udhcpc to report dhcp results with
  defp ensure_udhcpc_setup! do
    udhcpc_script="#!/bin/sh\necho [\necho status=\\'$1\\'\nset\necho ]\n"
    File.write! @udhcpc_script_path, udhcpc_script
    File.chmod! @udhcpc_script_path, 0o777
  end

  defp ip_cmd(cmd) do
    "/sbin/ip #{cmd}"
    |> os_cmd
    |> ip_response_to_status
  end

  # TODO this is horrible - lack of any kind of error checking
  defp ip_response_to_status(_ip_response) do
    :ok
  end

  # TODO below should likely be moved to public in Nerves.Utils
  defp os_cmd(cmd) do
    response = unlogged_os_cmd(cmd)
    Logger.debug "#{__MODULE__} os_cmd: #{inspect cmd} -> #{inspect response}"
    response
  end

  defp unlogged_os_cmd(cmd) do
    cmd
    |> :erlang.binary_to_list
    |> os_module.cmd
    |> :erlang.list_to_binary
  end

  # config underlying :os module to allow creating a mock for :os.cmd
  defp os_module do
    Application.get_env :nerves_io_ethernet, :os_module, :os
  end

  defp hostname(nil) do
    n = node
      |> to_string
      |> String.split("@")
      |> Enum.at(1)
    case n do
      nil -> @default_hostname
      host -> host
    end
  end
  defp hostname(host), do: host

end
