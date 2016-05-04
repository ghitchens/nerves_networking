alias Nerves.Networking
alias Networking.Test
alias Test.Mocks

# load required mocks

Code.require_file "mocks/os.exs", __DIR__
Code.require_file "mocks/ip.exs", __DIR__
Code.require_file "mocks/udhcpc.exs", __DIR__

defmodule Nerves.Networking.Test do

  require Logger
  use ExUnit.Case, async: true

  test "ethernet comes up configured in presence of dhcp server" do
    interface = :eth_401
    dhcp_config = %{ip: "10.0.0.5", router: "10.0.0.1", status: "bound", domain: "mynet.net",
                    mask: "8", subnet: "255.0.0.0", lease: "60",
                    dns1: "4.4.4.4", dns2: "6.6.6.6" }
    Mocks.IP.init interface
    Mocks.UDHCPC.init interface
    Mocks.UDHCPC.setup interface, dhcp_config
    {:ok, pid} = Networking.setup interface
    assert is_pid(pid)
    test_module_settings_match(interface, dhcp_config)
    test_ip_mock_matches(interface, dhcp_config)
  end

  test "ethernet handles different dhcp parameeters (renew)" do
    interface = :eth_202
    dhcp_config = %{ip: "192.168.12.88", router: "192.168.12.1", domain: "mynet.net.",
                    mask: "24", subnet: "255.255.255.0", lease: "60",
                    dns1: "4.4.4.4", dns2: "6.6.6.6", status: "renew"}
    Mocks.IP.init interface
    Mocks.UDHCPC.init interface
    Mocks.UDHCPC.setup interface, dhcp_config
    {:ok, pid} = Networking.setup interface
    assert is_pid(pid)
    test_module_settings_match(interface, dhcp_config)
    test_ip_mock_matches(interface, dhcp_config)
  end

  test "ethernet can be configured statically and reconfigured statically" do
    interface = :eth_s2
    static_config = %{ip: "10.0.0.5", router: "10.0.0.1",
               mask: "16", subnet: "255.255.0.0", mode: "static",
               dns1: "4.4.4.4", dns2: "6.6.6.6"}
    static_config2 = %{ip: "10.0.10.6", router: "10.0.10.1",
              mask: "16", subnet: "255.255.255.0", mode: "static",
              dns1: "4.4.4.4", dns2: "6.6.6.6"}
    Mocks.IP.init interface
    {:ok, pid} = Networking.setup interface, static_config
    assert is_pid(pid)
    test_module_settings_match(interface, static_config)
    test_ip_mock_matches(interface, static_config)
    _settings = Networking.configure interface, static_config2
    test_ip_mock_matches(interface, static_config2)
    test_module_settings_match(interface, static_config2)
  end

  test "ethernet can be reconfigured statically and then dynamically " do
    interface = :eth_209
    dhcp_config = %{ip: "192.168.12.88", router: "192.168.12.1", domain: "mynet.net.",
                    mask: "24", subnet: "255.255.255.0", lease: "60",
                    dns1: "4.4.4.4", dns2: "6.6.6.6", status: "renew"}
    static_config = [ip: "10.0.0.5", router: "10.0.0.1",
             mask: "16", subnet: "255.255.0.0", mode: "static",
             dns1: "4.4.4.4", dns2: "6.6.6.6"]
    Mocks.IP.init interface
    Mocks.UDHCPC.init interface
    Mocks.UDHCPC.setup interface, dhcp_config
    {:ok, pid} = Networking.setup interface
    assert is_pid(pid)
    test_module_settings_match(interface, dhcp_config)
    test_ip_mock_matches(interface, dhcp_config)
    _settings = Networking.configure interface, static_config
    test_ip_mock_matches(interface, static_config)
    test_module_settings_match(interface, static_config)
    _settings = Networking.configure interface, mode: "auto"
    test_ip_mock_matches(interface, dhcp_config)
    test_module_settings_match(interface, dhcp_config)
    assert is_pid(pid)
  end

  # test "dhcp ethernet that fails gets ipv4LL address" do
  #   interface = :eth_042
  #   Mocks.IP.init interface
  #   Mocks.UDHCPC.init interface
  #   {:ok, pid} = Networking.setup interface
  #   assert is_pid(pid)
  #   config = Networking.settings(interface)
  #   assert config.ip == "169.111.202.211"
  #   test_ip_mock_matches(interface, config)
  # end

  defp test_module_settings_match(interface, config) do
    # test to make sure network stack has proper settings
    net = Networking.settings(interface)
    Enum.map [:ip, :mask, :router, :lease], fn(key) ->
        assert net[key] == config[key]
    end
 end

 def test_ip_mock_matches(interface, config) do
    # test to see if the IP interface actually got configured
    ip_mock = Mocks.IP.settings(interface)
    Enum.map [:ip, :mask, :router], fn(key) ->
        assert ip_mock[key] == config[key]
    end
  end
end
