class nginx_web {

package { 'nginx':
  ensure => installed,
}
service { 'nginx':
  ensure => running,
  enable => true,
}
file { '/var/www/html/index.html':
  ensure  => file,
  content => "Built by Puppet on parsa's lab\n",
}
Package['nginx'] -> File['/var/www/html/index.html'] ~> Service['nginx']

}