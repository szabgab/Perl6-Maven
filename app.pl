use v6;

use lib 'lib';
use Bailador;

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

	get any('/atom', '/sitemap.xml', '/index.json') => sub {
		#return request.path;
		my $path = $meta ~ request.path;
		if $path.IO.e {
			return open($path).slurp-rest;
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
		my $start = now;
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
		my $lookup = from-json open("$meta/tutorial/lookup.json").slurp-rest;
		#return $lookup.perl;

		my $txt_file = "$source/pages/$file.txt";
		#return $txt_file;
		if $txt_file.IO ~~ :e {
			my $page = Perl6::Maven::Page.new(authors => $authors.authors, include => $include_dir, outdir => '');
			$page.read_file($txt_file, $file);
			if $lookup{$file} {
				#return $lookup{$file}.perl;
				for <prev_file prev_title next_file next_title> -> $field {
					$page.params{$field} = $lookup{$file}{$field};
				}
			}
			$page.params<github_link> = "https://github.com/szabgab/perl6maven.com/tree/main/pages/" ~ $page.params<url> ~ '.txt';
			my $content = $page.generate;
			my $end = now;
			my $elapsed = $end-$start;
			$content.=subst(/ELAPSED_TIME/, $elapsed);
			return $content;
		}

		if $file ~~ /tutorial\/(.*)/ {
			my $page = $/[0];
			my $json = "$meta/tutorial/slides.json".IO.slurp;
			my $slides_data = from-json $json;
			if $slides_data{$page} {
				return Perl6::Maven::Collector.create_chapters_page( $slides_data{$page} );
			}
		}

		status 404;
		return 'Not found';
	}

	baile;
}

