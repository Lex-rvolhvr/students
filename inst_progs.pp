class inst_progs {
  # puppet agent
  package { 'Puppet Agent (64-bit)':
    ensure          => '7.28.0',
    source          => 'https://downloads.puppetlabs.com/windows/puppet7/puppet-agent-7.28.0-x64.msi',
    install_options => ['PUPPET_AGENT_ENVIRONMENT=vpn'],
  }
  # winrar
  package { 'WinRAR 7.01 (64-бітна)':
    ensure          => '7.01.0',
    provider        => 'windows',
    source          => 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-701uk.exe',
    install_options => ['/S'],
  }
  file { 'C:\Program Files\WinRAR\rarreg.key':
    ensure  => file,
    source  => 'puppet:///files/common/rarreg.key',
    require => Package['WinRAR 7.01 (64-бітна)'],
  }
  # ovpn
    package { 'OpenVPN 2.6.11-I001 amd64':
      ensure   => '2.6.1101',
      provider => 'windows',
      source   => 'https://swupdate.openvpn.org/community/releases/OpenVPN-2.6.11-I001-amd64.msi',
  }
}
