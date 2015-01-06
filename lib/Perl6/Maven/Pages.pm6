class Perl6::Maven::Pages;

use Perl6::Maven::Page;
use Perl6::Maven::Tools;
use Perl6::Maven::Collector;


has $.source_dir;
has %.authors;
has $.outdir;
has $.include;


method save_pages() {
	debug("save pages");
	for Perl6::Maven::Collector.get_pages -> $p {
		process_template('page.tmpl', $p<url>, $p);
	}

	return;
}

method read_pages() {
	my %index;


	my @files = dir("$.source_dir").map({ $_.basename });
	
	debug('process pages of ' ~ @files.elems ~ ' files: ' ~ @files.perl);

	for @files -> $source_file {
		if substr($source_file, *-4) ne '.txt' {
			debug("Skipping '$source_file' it does not end with .txt");
			next;
		}
		debug("Source file $source_file");
		my $page = Perl6::Maven::Page.new(authors => %.authors, outdir => $.outdir, include => $.include);

		my %params = $page.read_file("$.source_dir/$source_file", substr($source_file, 0, chars($source_file) - 4));

		if not $page.status {
			debug("Skipping. No status in '$source_file'");
			next;
		}
		if $page.status ne 'show' {
			debug("Skipping Status is '{$page.status}' in '$source_file'");
			next;
		}

		Perl6::Maven::Collector.add_page(%params);
		# TODO how do I iterate over the array elents other than this work-around?
		for 0 .. %params<keywords>.elems -1  -> $i {
			my $k = %params<keywords>[$i];
			%index{$k}.push({ url => "/%params<url>" , title => %params<title> });
		}
	}

	Perl6::Maven::Collector.add_index(%index);
	return;
}


# vim: ft=perl6
# vim:noexpandtab
