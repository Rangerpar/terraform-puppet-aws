class profile::base {
  package { ['vim', 'curl', 'htop']:
    ensure => installed,
  }
}