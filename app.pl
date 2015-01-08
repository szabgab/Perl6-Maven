use v6;
use Bailador;

use lib 'lib';

use Perl6::Maven::Tools;
use Perl6::Maven::Collector;
use Perl6::Maven::Authors;
use Perl6::Maven::Page;


multi MAIN(
	Str  :$source!,
	Str  :$meta!,
	) {

	read_config($source);
	my $authors = Perl6::Maven::Authors.new( source_dir => $source);
	$authors.read_authors;


	get '/' => sub {
		my $main_json = "$meta/main.json".IO.slurp;
		return Perl6::Maven::Collector.create_main_page( $main_json );
	}


#get '/robots.txt' => sub {
#	"Sitemap: http://perl6maven.com/sitemap.xml";
#}

	#my $root = $*CWD;
	#if $*PROGRAM_NAME ~~ /\// {
	#}
	#my $$static_dir = "$root/files";
	my $pages_dir = "$source/pages";
	my $include_dir = "$source/files/";

#	my %CT = (
#		js  => 'application/javascript',
#		css => 'text/css',
#		png => 'image/png',
#		ico => 'image/x-icon',
#		gif => 'image/gif',
#		jpg => 'image/jpeg',
#	);

	get / '/' (.+) / => sub ($file) {
		#my $full_path = "$static_dir/$file";
	    #if $full_path.IO ~~ :e {
			# TODO set content-type !
			#my $ext = $full_path ~~ /\.(<[a..z]>+)$/;
			#if $ext and %CT{$ext} {
			#	content_type(%CT{$ext});
			#}
			#my $out = open($full_path, :r).read($full_path.IO.s);
			#return $out.Str;
		#}
		my $txt_file = "$source/pages/$file.txt";
		#return $txt_file;
		if $txt_file.IO ~~ :e {
			my $page = Perl6::Maven::Page.new(authors => $authors.authors, include => $include_dir, outdir => '');
			$page.read_file($txt_file, '');
			return $page.generate;
		}
		return 'Not found';
	}

	baile;
}

