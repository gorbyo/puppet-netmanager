#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::static', :type => 'define' do

  context 'incorrect value: ipaddress' do
    let(:title) { 'test77' }
    let :params do {
      :ensure    => 'up',
      :device    => 'eth77',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-test77')}.to raise_error(Puppet::Error, /notAnIP is not an IP address\./)
    end
  end

  context 'incorrect value: ipv6address' do
    let(:title) { 'test77' }
    let :params do {
      :ensure      => 'up',
      :device    => 'eth77',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6address => 'notAnIP',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-test77')}.to raise_error(Puppet::Error, /notAnIP is not an IPv6 address\./)
    end
  end

  context 'incorrect hash value: ipv6address' do
    let(:title) { 'test77' }
    let :params do {
      :ensure      => 'up',
      :device    => 'eth77',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6address => { 'notAn' => 'IP' },
    }
    end
    it 'should fail' do
      # there are major differences in the way that different ruby versions translate a hash into a string
      # which makes it hard to match the whole string
      expect {should contain_file('ifcfg-test77')}.to raise_error(Puppet::Error, /.*notAn.*IP.* is not an IPv6 address\./)
    end
  end

  context 'incorrect value: ipv6address in array' do
    let(:title) { 'test77' }
    let :params do {
      :ensure      => 'up',
      :device    => 'eth77',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6address => [
        '123:4567:89ab:cdef:123:4567:89ab:cdee',
        'notAnIP',
        '123:4567:89ab:cdef:123:4567:89ab:cdef',
      ]
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-test77')}.to raise_error(Puppet::Error, /notAnIP is not an IP\(v6\) address\./)
    end
  end

  context 'required parameters' do
    let(:title) { 'test1' }
    let :params do {
      :ensure    => 'up',
      :device    => 'eth1',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-test1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-test1',
      :notify => 'Exec[nmcli_config]'
    )}
    it 'should contain File[ifcfg-test1] with required contents' do
      verify_contents(catalogue, 'ifcfg-test1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=yes',
      ])
    end
    it { should contain_service('NetworkManager') }
  end

  context 'optional parameters' do
    let(:title) { 'test1' }
    let :params do {
      :ensure       => 'down',
      :device       => 'eth1',
      :ipaddress    => '1.2.3.4',
      :netmask      => '255.255.255.0',
      :gateway      => '1.2.3.1',
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :userctl      => true,
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :peerdns      => true,
      :dns1         => '3.4.5.6',
      :dns2         => '5.6.7.8',
      :domain       => 'somedomain.com',
      :ipv6init     => true,
      :ipv6autoconf => true,
      :ipv6peerdns  => true,
      :ipv6address  => '123:4567:89ab:cdef:123:4567:89ab:cdef/64',
      :ipv6gateway  => '123:4567:89ab:cdef:123:4567:89ab:1',
      :linkdelay    => '5',
      :scope        => 'peer 1.2.3.1',
      :defroute     => 'yes',
      :metric       => '10',
      :zone         => 'trusted',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-test1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-test1',
      :notify => 'Exec[nmcli_config]'
    )}
    it 'should contain File[ifcfg-test1] with required contents' do
      verify_contents(catalogue, 'ifcfg-test1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'GATEWAY=1.2.3.1',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'PEERDNS=yes',
        'DNS1=3.4.5.6',
        'DNS2=5.6.7.8',
        'DOMAIN="somedomain.com"',
        'USERCTL=yes',
        'IPV6INIT=yes',
        'IPV6_AUTOCONF=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cdef/64',
        'IPV6_DEFAULTGW=123:4567:89ab:cdef:123:4567:89ab:1',
        'IPV6_PEERDNS=yes',
        'LINKDELAY=5',
        'SCOPE="peer 1.2.3.1"',
        'DEFROUTE=yes',
        'ZONE=trusted',
        'METRIC=10',
        'NM_CONTROLLED=yes',
      ])
    end
    it { should contain_service('NetworkManager') }
  end

  context 'optional parameters - vlan' do
    let(:title) { 'eth6.203' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :macaddress_eth6 => 'bb:cc:bb:cc:bb:cc',
    }
    end
    it { should contain_file('ifcfg-eth6.203').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth6.203',
      :notify => 'Exec[nmcli_config]'
    )}
    it 'should contain File[ifcfg-eth6.203] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth6.203', [
        'DEVICE=eth6.203',
        'BOOTPROTO=none',
        'HWADDR=bb:cc:bb:cc:bb:cc',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'NM_CONTROLLED=yes',
      ])
    end
    it { should contain_service('NetworkManager') }
  end

  context 'optional parameters - manage_hwaddr' do
    let(:title) { 'test0' }
    let :params do {
      :ensure         => 'up',
      :device         => 'eth0',
      :ipaddress      => '1.2.3.4',
      :netmask        => '255.255.255.0',
      :manage_hwaddr  => false,
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :macaddress_eth0 => 'bb:cc:bb:cc:bb:cc',
    }
    end
    it { should contain_file('ifcfg-test0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-test0',
      :notify => 'Exec[nmcli_config]'
    )}
    it 'should contain File[ifcfg-test0] with required contents' do
      verify_contents(catalogue, 'ifcfg-test0', [
        'DEVICE=eth0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'NM_CONTROLLED=yes',
      ])
    end
    it { should contain_service('NetworkManager') }
  end

  context 'flush => true - ip addr flush' do
    let(:title) { 'test1' }
    let :params do {
      :ensure    => 'up',
      :device    => 'eth1',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :flush     => true
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_exec('network-flush').with_command('ip addr flush dev eth1').that_comes_before('Exec[nmcli_manage]') }
  end

  context 'optional parameters - single ipv6address in array' do
    let(:title) { 'test1' }
    let :params do {
      :ensure      => 'up',
      :device      => 'eth1',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6init    => true,
      :ipv6address => [
        '123:4567:89ab:cdef:123:4567:89ab:cdee',
      ],
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-test1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-test1',
      :notify => 'Exec[nmcli_config]'
    )}
    it 'should contain File[ifcfg-test1] with required contents' do
      verify_contents(catalogue, 'ifcfg-test1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'IPV6INIT=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cdee',
        'NM_CONTROLLED=yes',
      ])
    end
    it { should contain_service('NetworkManager') }
  end

  context 'optional parameters - multiple ipv6addresses' do
    let(:title) { 'test1' }
    let :params do {
      :ensure      => 'up',
      :device      => 'eth1',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6init    => true,
      :ipv6address => [
        '123:4567:89ab:cdef:123:4567:89ab:cded',
        '123:4567:89ab:cdef:123:4567:89ab:cdee',
        '123:4567:89ab:cdef:123:4567:89ab:cdef',
      ],
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-test1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-test1',
      :notify => 'Exec[nmcli_config]'
    )}
    it 'should contain File[ifcfg-test1] with required contents' do
      verify_contents(catalogue, 'ifcfg-test1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'IPV6INIT=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cded',
        'IPV6ADDR_SECONDARIES="123:4567:89ab:cdef:123:4567:89ab:cdee 123:4567:89ab:cdef:123:4567:89ab:cdef"',
        'NM_CONTROLLED=yes',
      ])
    end
    it { should contain_service('NetworkManager') }
  end
end
