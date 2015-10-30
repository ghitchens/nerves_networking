alias Nerves.IO.Ethernet
alias Ethernet.Test
alias Test.Mocks

# load required mocks

Code.require_file "mocks/os.exs", __DIR__
Code.require_file "mocks/ip.exs", __DIR__
Code.require_file "mocks/udhcpc.exs", __DIR__

defmodule Nerves.IO.Ethernet.Test do

  require Logger
  use ExUnit.Case, async: true

  test "ethernet comes up configured in presence of dhcp server" do
    interface = :eth_401
    dhcp_config = %{ip: "10.0.0.5", router: "10.0.0.1", status: "bound",
                    mask: "8", subnet: "255.0.0.0", lease: "60",
                    dns1: "4.4.4.4", dns2: "6.6.6.6" }
    Mocks.IP.init interface
    Mocks.UDHCPC.init interface
    Mocks.UDHCPC.setup interface, dhcp_config
    {:ok, pid} = Ethernet.setup interface
    assert is_pid(pid)
    test_module_settings_match(interface, dhcp_config)
    test_ip_mock_matches(interface, dhcp_config)
  end

  test "ethernet handles different dhcp parameeters (renew)" do
    interface = :eth_202
    dhcp_config = %{ip: "192.168.12.88", router: "192.168.12.1",
                    mask: "24", subnet: "255.255.255.0", lease: "60",
                    dns1: "4.4.4.4", dns2: "6.6.6.6", status: "renew"}
    Mocks.IP.init interface
    Mocks.UDHCPC.init interface
    Mocks.UDHCPC.setup interface, dhcp_config
    {:ok, pid} = Ethernet.setup interface
    assert is_pid(pid)
    test_module_settings_match(interface, dhcp_config)
    test_ip_mock_matches(interface, dhcp_config)
  end

  test "ethernet can be configured statically" do
    interface = :eth_s2
    static_config = %{ip: "10.0.0.5", router: "10.0.0.1",
               mask: "16", subnet: "255.255.0.0", mode: "static",
               dns1: "4.4.4.4", dns2: "6.6.6.6"}
    Mocks.IP.init interface
    {:ok, pid} = Ethernet.setup interface, static_config
    assert is_pid(pid)
    test_module_settings_match(interface, static_config)
    test_ip_mock_matches(interface, static_config)
  end

  # test "dhcp ethernet that fails gets ipv4LL address" do
  #   interface = :eth_042
  #   Mocks.IP.init interface
  #   Mocks.UDHCPC.init interface
  #   {:ok, pid} = Ethernet.setup interface
  #   assert is_pid(pid)
  #   config = Ethernet.settings(interface)
  #   assert config.ip == "169.111.202.211"
  #   test_ip_mock_matches(interface, config)
  # end

  defp test_module_settings_match(interface, config) do
    # test to make sure network stack has proper settings
    net = Ethernet.settings(interface)
    assert net.ip == config.ip
    assert net.mask == config.mask
    assert net.router == config.router
    assert net[:lease] == config[:lease]
    assert net.mask == config.mask
 end

 def test_ip_mock_matches(interface, config) do
    # test to see if the IP interface actually got configured
    ip_mock = Mocks.IP.settings(interface)
    assert ip_mock.ip == config.ip
    assert ip_mock.mask == config.mask
    assert ip_mock.router == config.router
  end
end
