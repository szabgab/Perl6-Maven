use Perl6::Maven::Pages;
class Perl6::Maven::Slides is Perl6::Maven::Pages;

has %.slides;

use Perl6::Maven::Collector;
use Perl6::Maven::Tools;


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
			%.slides{$id}<pages>.push({ id => "$/[0]" });
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
			$prev_page<next_file> = "$.outdir$id";
			$prev_page<next_title> = %.slides{$id}<title>;
		}

		$prev_obj = %.slides{$id};
		$prev_file = "$.outdir$id";
		$prev_title = %.slides{$id}<title>;
		$prev_page = Any;

		for %.slides{$id}<pages>.list -> $p {
			debug("slide $p<id>");
			my $page = Perl6::Maven::Collector.get_page( "$.outdir$p<id>" );
			if not $page {
				die "Missing page for '$p<id>'. Is there a typo in pages.yml ?"; 
			}

			$p<show_toc_button> = 1;

			$p<title> = $page<title>;
			$p<prev_file> = $page<prev_file>  = $prev_file;
			$p<prev_title> = $page<prev_title> = $prev_title;

			if $prev_page {
				$prev_page<next_file> = "$.outdir$p<id>";
				$prev_page<next_title> = $page<title>;
			} elsif $prev_obj {
				$prev_obj<next_file> = "$.outdir$p<id>";
				$prev_obj<next_title> = $page<title>;
			}

			$prev_page = $page;
			$prev_file = $page<url>;
			$prev_title = $page<title>;
		}
	}
}

method save_indexes() {
	my @chapters;
	for %.slides.keys -> $id {
		#debug("ID $id");
		%.slides{$id}<content> //= '';
		process_template('slides_chapter.tmpl', "tutorial/$id", %.slides{$id});
		%.slides{$id}<id> = $id;
		@chapters.push(%.slides{$id});
	}
	my %data = (
		title => "The Perl Maven's Perl 6 Tutorial",
		chapters => @chapters,
		content => ''
	);

	process_template('slides_toc.tmpl', "tutorial/toc", %data);
}

# vim: ft=perl6
# vim:noexpandtab

