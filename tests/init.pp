include apache2 apache2::virtualhost {
	"example.com" :
		serveraliase => "www.example.com",
		php_admin_value => undef,
		domain_id => 4000,
		password => 'test',
}