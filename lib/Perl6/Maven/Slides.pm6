class Perl6::Maven::Slides;

has $.file;
has %.slides;

use Perl6::Maven::Tools;


# AFAIK There is no real YAML reader for Perl 6 yet, so this implements the subset we use.
method read_yml() {
	# temporary hard-coding
	my $fh = open $.file, :r;
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
	
		die "Line could not be recognized in $.file <$line>";
	}
}

method save() {
	my @chapters;
	for %.slides.keys -> $id {
		#debug("ID $id");
		for %.slides{$id}<pages>.list -> $p {
			#say $p.perl;
			#say "   $p<id>";
			$p<title> = "Title of $p<id>";
		}
		process_template('slides_chapter.tmpl', "tutorial/$id", { title => %.slides{$id}<title>, pages => %.slides{$id}<pages>, content => '' });
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
 
