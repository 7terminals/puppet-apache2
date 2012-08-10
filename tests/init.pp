include apache2 apache2::virtualhost {
	"example.com" :
		subdomains => "www.example.com",
		php_admin_value => undef,
		domain_id => 4000,
		password => 'test',
}