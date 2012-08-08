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
			$webserver_packages = ['php-common', 'php-imap', 'php-mbstring',
			'php-pecl-mailparse', 'php-pdo', 'unixODBC-libs', 'php-odbc', 'php-mysql',
			'php-xmlrpc', 'httpd', 'php-xml', 'php-soap', 'php-mcrypt', 'php-pecl-apc',
			'php-gd-5', 'GeoIP', 'glibc', 'mod_geoip']
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
			group => root,
	}
	file {
		'/var/lib/puppet/cache/make_chroot_webserver.sh' :
			content => template("${module_name}/make_chroot_webserver.sh"),
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
