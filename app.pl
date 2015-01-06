use v6;
use Bailador;

get '/' => sub {
	'root';
}


#get '/robots.txt' => sub {
#	"Sitemap: http://perl6maven.com/sitemap.xml";
#}

#my $static_dir = '/home/gabor/work/perl6maven-live.com/
my $static_dir = '/home/gabor/work/Perl6-Maven/files';
my $config_file = '/home/gabor/work/perl6maven.com/config.ini';
my $authors_file = '/home/gabor/work/perl6maven.com/authors.txt';
my $pages_dir = '/home/gabor/work/perl6maven.com/pages';
my $include_dir ='/home/gabor/work/perl6maven.com/files'; 

get / '/' (.+) / => sub ($file) {
    if "$static_dir/$file".IO ~~ :e {
		# TODO set content-type !
    	return "$static_dir/$file".IO.slurp
	}
	return 'Not found';
}


baile;
