class {
	"apache2" :
		serveradmin => "hello@example.com",
}
apache2::virtualhost {
	"example.com" :
		serveraliase => "www.example.com",
		serveradmin => "me@example.com",
		php_admin_value => undef,
		domain_id => 4000,
		password => 'test',
}