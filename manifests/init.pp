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
class apache2 ($base_chroot_dir = '/webserver',
	$port = 80) {
	case $::operatingsystem {
		debian, ubuntu : {
		}
		centos, redhat, oel, linux, fedora : {
			$webserver_packages = ['php-common', 'php-imap', 'php-mbstring',
			'php-pecl-mailparse', 'php-pdo', 'unixODBC-libs', 'php-odbc', 'php-mysql',
			'php-xmlrpc', 'httpd', 'php-xml', 'php-soap', 'php-mcrypt', 'php-pecl-apc',
			'php-gd', 'GeoIP', 'glibc', 'mod_geoip']
			$apache_conf_file = "redhat-httpd.conf.erb"
			$php_conf_file = "redhat-php.ini.erb"
			$init_script_name = "httpd"
			$init_script = "redhat-httpd.erb"
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
		'/etc/httpd/conf/httpd.conf' :
			content => template("${module_name}/$apache_conf_file"),
			owner => root,
			group => root,
			require => Package[$webserver_packages],
	}
	file {
		'/etc/php.ini' :
			content => template("${module_name}/$php_conf_file"),
			owner => root,
			group => root,
			require => Package[$webserver_packages],
	}
	file {
		"/etc/init.d/$init_script_name" :
			content => template("${module_name}/$init_script"),
			owner => root,
			group => root,
			require => Package[$webserver_packages],
	}
	file {
		'/var/lib/puppet/cache' :
			ensure => directory,
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
			require => [File['/var/lib/puppet/cache/make_chroot_webserver.sh'],
			File['/etc/httpd/conf/httpd.conf', '/etc/php.ini']],
			notify => Service['httpd'],
			refreshonly => true,
	}
} 