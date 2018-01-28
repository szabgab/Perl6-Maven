unit class Perl6::Maven;
use Bailador;

use Perl6::Maven::Tools;
use Perl6::Maven::Collector;
use Perl6::Maven::Authors;
use Perl6::Maven::Page;
#use JSON::Tiny;

# The web application

has $.source;
has $.meta;

method run () {
	read_config($.source);
	my $authors = Perl6::Maven::Authors.new( source_dir => $.source);
	$authors.read_authors;


	get '/' => sub {
		my $json = slurp("$.meta/main.json");
		return Perl6::Maven::Collector.create_main_page( $json );
	}

	get '/atom' => sub {
		my $path = $.meta ~ request.path;
		return slurp($path);
    }
	get '/sitemap.xml' => sub {
		my $path = $.meta ~ request.path;
		return slurp($path);
    }
	get '/index.json' => sub {
		my $path = $.meta ~ request.path;
		return slurp($path);
    }


	get '/index' => sub {
		my $json = slurp("$.meta/index.json");
		return Perl6::Maven::Collector.create_index_page( $json );
	}

	get '/archive' => sub {
		my $json = slurp("$.meta/archive.json");
		return Perl6::Maven::Collector.create_archive_page( $json );
	}

	get '/tutorial/toc' => sub {
		my $json = slurp("$.meta/tutorial/slides.json");
		return Perl6::Maven::Collector.create_toc_page( $json );
	}


#get '/robots.txt' => sub {
#	"Sitemap: http://perl6maven.com/sitemap.xml";
#}

	my $pages_dir = "$.source/pages";
	my $include_dir = "$.source/files/";

	get / '/' (.+) / => sub ($file is copy) {
		my $start = now;
		if $file ~~ /\/$/ {
			$file ~= 'main';
		}
		my $lookup = from-json slurp("$.meta/tutorial/lookup.json");
		#return $lookup.perl;

		my $txt_file = "$.source/pages/$file.txt";
		#return $txt_file;
		if $txt_file.IO.e {
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
			my $json = slurp("$.meta/tutorial/slides.json");
			my $slides_data = from-json $json;
			if $slides_data{$page} {
				return Perl6::Maven::Collector.create_chapters_page( $slides_data{$page} );
			}
		}

		warning("Path to '$file' not found");

		status 404;
		return 'Not found';
	}

	baile;
}

# vim: ft=perl6
# vim:noexpandtab

