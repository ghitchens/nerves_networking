defmodule Nerves.Networking do

  @moduledoc """
  Manages one or more network interfaces on a nerves-based system.

  ## Basic Usage

  ```elixir
  alias Nerves.Networking
  Networking.setup :eth0, state: auto
  ```
  Sets up (configures) an adapter with the associated settings. The above
  will try to acquire a ipv4 address via DHCP, reverting to AIPA/ipv4ll
  addressing configuration if that fails, while retrying DHCP occasionally.

  ```elixir
  Networking.setup :eth0, mode: static, address: "192.168.5.8",
        router: "192.168.5.1", mask: "255.255.255.0"
  ```
  Forces static configuration.

  ## Notes about AIPA / ipv4ll addressing

  If a DHCP IP cannot be obtained, `Nerves.Networking` automatically
  configures an address on te 169.254.0.0/16 network.  Microsoft
  calls this AIPA, and the IETF calls it ipv4ll (ipv4 link local)
  addressing.

  Once a node has an ipv4ll address, it broadcasts a DHCP DISCOVER
  packet on a regular basis to see if a DHCP server re-appears. The
  time of this rebroadcast is progressive (see `ip4ll_dhcp_retry_time`).

  ## Interface Status

  Any of the interfaces can be in one a few different states, which are
  both set and read as `:status` in the settings of the adapter.  The
  following are valid application

  * `:bound` The interface is in DHCP mode, and currently bound to an address.
  * `:ipv4ll` The interface is in DHCP mode, but DHCP has not yet succeeded,
  and the interface has fallen back into DHCP mode.
  * The `:hostname` option may be used to specify the hostname to pass during
  a DHCP request.

  ### Static config at compile time

  The `:ip` option may be used to specify a static ip address.

  The `:subnet` option is used to specify the subnet for the interface.
  Example: `255.255.0.0`

  The `:mask` option is used to specify the subnet mask. Example: 16

  The `:router` option used to specify the ip address of the router IP address.

  The `:dns` option is used to specify the ip address of the DNS server.
  Example: `["8.8.8.8", "4.4.4.4"]`

  """

  use Application
  require Logger

  alias Nerves.Networking

  @type interface :: Networking.Subsystem.interface
  @type settings :: Dict.t
  @type reason :: Networking.Subsystem.interface

  def start(_type, _args) do
    Logger.debug "#{__MODULE__} Starting"
    Networking.Subsystem.initialize
    {:ok, self}  # need supervisor
  end

  @doc """
  Configure and start managing an Networking interface.
  """
  @spec setup(interface, settings) :: {:ok, pid} | {:error, reason}
  def setup(interface, settings \\ []) do
    Logger.debug "#{__MODULE__} Setup(#{interface}, #{inspect settings})"
    GenServer.start(Nerves.Networking.Server, {interface, settings},
                    [name: interface_process(interface)])
  end

  @doc """
  Return the current settings on an interface.
  """
  @spec settings(interface) :: settings
  def settings(interface) do
    interface
    |> interface_process
    |> GenServer.call(:settings)
  end

  # return a process name for a process
  defp interface_process(interface), do: interface

end
