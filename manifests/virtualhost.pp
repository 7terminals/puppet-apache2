define apache2::virtualhost ($servername = $name,
	$serveraliase,
	$virtualhost_config_path = "${apache2::base_chroot_dir}/etc/httpd/conf.d",
	$php_admin_value = undef,
	$domain_id = undef,
	$password = undef) {
	File {
		ensure => 'directory',
		owner => ${servername},
		group => ${servername},
		mode => '644',
		require => Service["$apache2::init_script"],
	}
	group {
		$servername :
			name => $servername,
			ensure => present,
			gid => $domain_id,
	}
	user {
		$servername :
			name => $servername,
			ensure => present,
			comment => $servername,
			gid => $domain_id,
			home => "${apache2::base_chroot_dir}/home/${servername}",
			managehome => true,
			password => $password,
			shell => '/bin/bash',
			uid => $domain_id,
			require => Group[$servername],
	}
	file {
		"${virtualhost_config_path}/${servername}.conf" :
			ensure => file,
			content => template("${module_name}/virtualhost.conf.erb"),
			require =>
			Exec['sh /var/lib/puppet/cache/make_chroot_webserver.sh'],
			notify => Service['httpd'],
	}
	file {
		"${apache2::base_chroot_dir}/home/${servername}" :
			require => File["${virtualhost_config_path}/${servername}.conf"],
	}
	file {
		"${apache2::base_chroot_dir}/home/${servername}/www" :
			require => File["${apache2::base_chroot_dir}/home/${servername}"],
	}
	file {
		"${apache2::base_chroot_dir}/home/${servername}/logs" :
			require => File["${apache2::base_chroot_dir}/home/${servername}"],
	}
	file {
		"${apache2::base_chroot_dir}/home/${servername}/tmp" :
			require => File["${apache2::base_chroot_dir}/home/${servername}"],
			mode => '600',
	}
}