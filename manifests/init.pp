# Class: apache2
#
# This module manages puppet-apache2
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class apache2 {
	case $::operatingsystem {
		debian, ubuntu : {
		}
		centos, redhat, oel, linux, fedora : {
			$webserver_packages = ['httpd', 'php', 'php-cli', 'php-common', 'php-devel',
			'php-gd', 'php-imap', 'php-mbstring', 'php-mcrypt', 'php-mysql', 'php-odbc',
			'php-pdo', 'php-pear', 'php-pecl-memcache', 'php-soap', 'php-xml',
			'php-xmlrpc', 'php-pecl-apc', 'php-pecl-mailparse', 'glibc', 'pcre',
			'expat', 'apr', 'openssl', 'mod_security', 'zlib-devel', 'openssl-devel',
			'libtool', 'mod_geoip', 'GeoIP-devel', 'httpd-devel']
		}
		default : {
			$supported = false
			notify {
				"${module_name}_unsupported" :
					message =>
					"The ${module_name} module is not supported on ${::operatingsystem}",
			}
		}
	}
	package {
		$webserver_packages :
			ensure => installed,
	}
	file {
		'/var/lib/puppet/cache' :
			ensure => directory,
			owner => root,
			group => root.
	}
	file {
		'/var/lib/puppet/cache/make_chroot_webserver.sh' :
			source => template("${module_name}/make_chroot_webserver.sh"),
			require => [Package[$webserver_packages], File['/var/lib/puppet/cache']],
			notify => Exec['sh /var/lib/puppet/cache/make_chroot_webserver.sh'],
	}
	exec {
		'sh /var/lib/puppet/cache/make_chroot_webserver.sh' :
			path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin',
			'/bin', '/sbin'],
			logoutput => true,
			require => File['/var/lib/puppet/cache/make_chroot_webserver.sh'],
			/*notify => Service['httpd'],*/
			refreshonly => true,
	}
}
