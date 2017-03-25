use Perl6::Maven::Pages;
unit class Perl6::Maven::Slides is Perl6::Maven::Pages;

has %.slides;

use Perl6::Maven::Collector;
use Perl6::Maven::Tools;

use JSON::Tiny;

# AFAIK There is no real YAML reader for Perl 6 yet, so this implements the subset we use.
method read_yml() {
	# temporary hard-coding
	my $file = "$.source_dir/pages.yml";
	my $fh = open $file, :r;
	my $id;
	for $fh.lines -> $line {
		#if $line ~~ /^\- id\: ([\w\-]+)$/ {
		if $line ~~ /^\-<space>id\:<space>(.*)/ {
			$id = "$/[0]";
			#say "Match $id";
			next;
		}

		if $line ~~ /^<space>*title\:<space>(.*)/ {
			%.slides{$id}<title> = "$/[0]";
			next;
		}
		if $line ~~ /^<space>*pages\:/ {
			next;
		}

		if $line ~~ /^<space>*\-<space>(.*)/ {
			my %h = id => "$/[0]";
			%.slides{$id}<pages>.push: $%h;
			next;
		}
		if $line ~~ /^<space>*$/ {
			next;
		}
	
		die "Line could not be recognized in $file <$line>";
	}
}

method update_slides() {
	my $prev_file  = '';
	my $prev_title = '';
	my $prev_obj;
	my $prev_page;
	#debug(%.slides.perl);
	for %.slides.keys -> $id {
		debug("chapter $id");
		%.slides{$id}<prev_file> = $prev_file;
		%.slides{$id}<prev_title> = $prev_title;

		if $prev_page {
			$prev_page.params<next_file> = "$.outdir$id";
			$prev_page.params<next_title> = %.slides{$id}<title>;
		}

		$prev_obj = %.slides{$id};
		$prev_file = "$.outdir$id";
		$prev_title = %.slides{$id}<title>;
		$prev_page = Any;

		for %.slides{$id}<pages>.list -> $p {
			debug("slide $p<id>");
			my $page = Perl6::Maven::Collector.get_page( "$.outdir$p<id>" );
			if not $page {
				warn "Missing page for '$p<id>'. Is there a typo in $.source_dir/pages.yml ?";
				next;
			}

			$p<show_toc_button> = 1;

			$p<title> = $page.params<title>;
			$p<prev_file> = $page.params<prev_file>  = $prev_file;
			$p<prev_title> = $page.params<prev_title> = $prev_title;

			if $prev_page {
				$prev_page.params<next_file> = "$.outdir$p<id>";
				$prev_page.params<next_title> = $page.params<title>;
			} elsif $prev_obj {
				$prev_obj<next_file> = "$.outdir$p<id>";
				$prev_obj<next_title> = $page.params<title>;
			}

			$prev_page = $page;
			$prev_file = $page.params<url>;
			$prev_title = $page.params<title>;
		}
	}
}

method get_slides_json() {
	return to-json %.slides.item;
}

# vim: ft=perl6
# vim:noexpandtab

