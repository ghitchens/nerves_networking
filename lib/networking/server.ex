defmodule Nerves.Networking.Server do
  @moduledoc false

  alias Nerves.Networking.Subsystem
  use GenServer
  require Logger

  @public_keys [
    :interface, :hostname, :status, :dhcp_retries, :type, :ntpsrv, :ip,
    :subnet, :mask, :timezone, :router, :timesvr, :dns, :domain, :broadcast,
    :ipttl, :broadcast, :opt53, :lease, :dhcptype, :serverid, :message,
    :mode
  ]

  def init({interface, config}) do
    Logger.debug "#{__MODULE__}.init(#{inspect interface}): #{inspect config}"
    Subsystem.link_set(interface, :up)
    {:ok, ref} = GenEvent.start_link()
    %{notifier: ref, interface: interface, mode: "auto", status: "init",
      dhcp_retries: 0}
    |> configure(config)
    |> respond(:ok)  # REVIEW handle errors properly?!!?
  end

  def handle_call({:configure, config}, _from, state) do
    configure(state, config)
    |> reply_with_settings
  end

  def handle_call(:settings, _from, state) do
    reply_with_settings(state)
  end

  defp reply_with_settings(state) do
    {:reply, settings(state), state}
  end

  # return keys from state that are included in "settings"
  defp settings(state) do
    Dict.take(state, @public_keys)
  end

  # given settings, apply to state, and setup interface accordingly
  defp configure(state, settings) do
    Logger.debug "#{__MODULE__} configure(#{inspect state}, #{inspect settings})"
    if static_settings?(settings) do
      static_config = Dict.merge(settings, %{lease: nil, mode: "static"})
      configure_interface(state, static_config)
    else
      configure_with_dynamic_ip(state)
    end
  end

  # true if settings appear to imply a static configuration
  defp static_settings?(settings) do
    settings[:ip] || settings[:mask] || (settings[:subnet]) || (settings[:mode]=="static")
  end

  # try renewing dhcp lease upon expiration unless we've been configured
  # as a static ip in the meantime
  def handle_info(:dhcp_lease_expired, state) do
    state.status
    |> renew_dhcp(state)
    |> respond(:noreply)
  end

  # called periodically to try to see if a dhcp server came back
  # online
  def handle_info(:ip4ll_dhcp_retry, state) do
    params = raw_dhcp_request(state)
    params[:status]
    |> conf_dhcp_on_status(state, params)
    |> respond(:noreply)
  end

  defp renew_dhcp("static", state), do: state
  defp renew_dhcp(_, state), do: configure_with_dynamic_ip(state)

  defp conf_dhcp_on_status("bound", state, params), do: configure_dhcp(state, params)
  defp conf_dhcp_on_status("renew", state, params), do: configure_dhcp(state, params)
  defp conf_dhcp_on_status(_, state, _), do: schedule_ip4ll_dhcp_retry(state)

  defp schedule_ip4ll_dhcp_retry(state) do
    interval = dhcp_retry_interval(state.dhcp_retries)
    retry =  state.dhcp_retries + 1
    #Logger.debug "scheduling dhcp retry ##{retry} for #{interval} ms"
    :erlang.send_after interval, Kernel.self, :ip4ll_dhcp_retry
    update_and_announce state, dhcp_retries: retry
  end

  # retry after 10 seconds for the first 10 retries, then 1 min
  defp dhcp_retry_interval(tries) when tries >= 10, do: 60000
  defp dhcp_retry_interval(_tries), do: 10000

  # update changes and announce, returning new state
  defp update_and_announce(state, changes) do
    public_changes = Dict.take changes, @public_keys
    if Enum.any?(public_changes) and state[:on_change] do
      state.on_change.(public_changes)
    end
    Dict.merge(state, changes)
  end

  # setup the interface to have a dynamic (dhcp or ip4ll) address
  defp configure_with_dynamic_ip(state) do # -> new_state
    Logger.debug "starting dynamic ip allocation"
    state = update_and_announce state, status: "request"
    params = raw_dhcp_request(state)
    case params[:status] do
      "bound" ->
        configure_dhcp(state, params)
      "renew" ->
        configure_dhcp(state, params)
      _ ->
        configure_ip4ll(state)
    end
  end

  defp raw_dhcp_request(state) do
    Subsystem.dhcp_request(state.interface, state[:hostname])
  end

  defp configure_dhcp(state, params) do
    state = %{state | dhcp_retries: 0 }
    if Dict.has_key?(params, :lease) do
      lease = :erlang.binary_to_integer(params[:lease])
      :erlang.send_after lease*1000, Kernel.self, :dhcp_lease_expired
    end
    configure_interface(state, params)
  end

  defp configure_interface(state, params) do
    interface = state.interface
    Logger.debug "#{Subsystem} configure: #{interface}, #{inspect params}"
    if params[:ip] && params[:mask] do
      Subsystem.flush_addresses(interface)
      Subsystem.add_address(interface, params[:ip], params[:mask])
      case params[:router] do
        nil -> nil
        router -> Subsystem.set_router(interface, router)
      end
      case {params[:dns], params[:domain]} do
        {nil, _} -> nil
        {dns, domain} -> Subsystem.set_resolv_conf(dns, domain)
      end
    end
    update_and_announce(state, params)
  end

  # setup an ipv4ll address (autoconfigured address) with timer
  defp configure_ip4ll(state) do
    params = ip4ll_params(state)
    schedule_ip4ll_dhcp_retry(state)
    configure_interface(state, params)
  end

  defp ip4ll_params(state) do
    [ interface: state.interface, ip: calculate_ip4ll_ip_from_state(state),
    mask: "16", subnet: "255.255.0.0",  status: "ip4ll", dhcp_retries: 0 ]
  end

  defp calculate_ip4ll_ip_from_state(state) do
    state.interface
    |> Subsystem.mac_address
    |> mac_to_proposed_ip4ll_address
  end

  defp mac_to_proposed_ip4ll_address(mac_address) do
    <<x, y, _rest :: bytes>> = :crypto.hash(:md5, mac_address)
    r = case {x, y} do
      {255, 255} -> 254
      {0, 0} -> 5
      _ -> y
    end
    "169.254.#{x}.#{r}"
  end

  defp respond(t, atom), do: {atom, t}

end
