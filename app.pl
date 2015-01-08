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
		my $json = "$meta/main.json".IO.slurp;
		return Perl6::Maven::Collector.create_main_page( $json );
	}

	get any('/atom', '/sitemap.xml') => sub {
		#return request.path;
		my $path = $meta ~ request.path;
		if $path.IO.e {
			return open($path).slurp;
		}
	}

	get '/index' => sub {
		my $json = "$meta/index.json".IO.slurp;
		return Perl6::Maven::Collector.create_index_page( $json );
	}

	get '/archive' => sub {
		my $json = "$meta/archive.json".IO.slurp;
		return Perl6::Maven::Collector.create_archive_page( $json );
	}

	get '/tutorial/toc' => sub {
		my $json = "$meta/tutorial/slides.json".IO.slurp;
		return Perl6::Maven::Collector.create_toc_page( $json );
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

	get / '/' (.+) / => sub ($file is copy) {
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
		if $file ~~ /\/$/ {
			$file ~= 'main';
		}
		my $txt_file = "$source/pages/$file.txt";
		#return $txt_file;
		if $txt_file.IO ~~ :e {
			my $page = Perl6::Maven::Page.new(authors => $authors.authors, include => $include_dir, outdir => '');
			$page.read_file($txt_file, '');
			return $page.generate;
		}

		if $file ~~ /tutorial\/(.*)/ {
			my $page = $/[0];
			my $json = "$meta/tutorial/slides.json".IO.slurp;
			my $slides_data = from-json $json;
			if $slides_data{$page} {
				return Perl6::Maven::Collector.create_chapters_page( $slides_data{$page} );
			}
		}

		return 'Not found';
	}

	baile;
}

