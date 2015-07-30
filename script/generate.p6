#!/usr/bin/env perl6
use v6;

use lib 'lib';

use Perl6::Maven::Tools;
use Perl6::Maven::Pages;
use Perl6::Maven::Collector;
use Perl6::Maven::Slides;
use Perl6::Maven::Authors;

multi MAIN(Bool :$help!) {
	say 'no param' if  not $help;
	usage();
}

multi MAIN(
	Str  :$indir   is copy,
	Str  :$outdir!,
	Bool :$pages = False,
	Bool :$all = False,
	) {
	usage("--indir was missing") if not $indir;
	usage('avoid updirs') if $outdir ~~ m/\.\./;

	read_config($indir);
	my $authors = Perl6::Maven::Authors.new( source_dir => $indir);
	$authors.read_authors;

	# If the user tries to pass --outdir ~/tmp/perl6maven the code will receive the ~ without the shell expanding it
	# Let's avoid creating a directory called ~
	for $indir, $outdir -> $dir {
		usage("You cannot pass ~ in the path '$dir'") if $dir ~~ m/\~/;
	}

	mkpath $outdir;
	if $pages {
		shell("cp -r files/* $outdir"); # TODO Perl based recursive copy!
	}
	set_outdir($outdir);


	my %index;
	my $pm_pages = Perl6::Maven::Pages.new(source_dir => "$indir/pages", authors => $authors.authors, outdir => '', include => "$indir/files/");
	$pm_pages.read_pages;
	$pm_pages.save_pages(sub ($file) { return "$outdir/$file" }, $all) if $pages;

	my $slides = Perl6::Maven::Slides.new(source_dir => "$indir/pages/tutorial", authors => $authors.authors, outdir => 'tutorial/', include => "$indir/files/");
	$slides.read_yml;
	$slides.read_pages;
	$slides.update_slides;
	my $lookup_json = Perl6::Maven::Collector.get_lookup_json();
	save_file( "$outdir/tutorial/lookup.json", $lookup_json );
	$slides.save_pages(sub ($file) { return "$outdir/$file" }, $all) if $pages;
	my $slides_json = $slides.get_slides_json();
	save_file( "$outdir/tutorial/slides.json", $slides_json );
	my $slides_data = from-json $slides_json;
	if $pages {
		save_file( "$outdir/tutorial/toc", Perl6::Maven::Collector.create_toc_page($slides_json));
		for $slides_data.keys -> $id {
			save_file( "$outdir/tutorial/$id", Perl6::Maven::Collector.create_chapters_page( $slides_data{$id} ) );
		}
	}

	my $main_json = Perl6::Maven::Collector.get_main_json();
	save_file( "$outdir/main.json", $main_json );
	save_file( "$outdir/main", Perl6::Maven::Collector.create_main_page( $main_json ) ) if $pages;

	my $index_json = Perl6::Maven::Collector.get_index_json();
	save_file( "$outdir/index.json", $index_json  );
	save_file( "$outdir/index", Perl6::Maven::Collector.create_index_page( $index_json ) ) if $pages;

	my $archive_json = Perl6::Maven::Collector.get_archive_json();
	save_file( "$outdir/archive.json", $archive_json  );
	save_file( "$outdir/archive", Perl6::Maven::Collector.create_archive_page($archive_json) ) if $pages;

	save_file( "$outdir/atom", Perl6::Maven::Collector.create_atom_feed);
	save_file( "$outdir/sitemap.xml", Perl6::Maven::Collector.create_sitemap());

}

sub usage($msg?) {
	say $msg if $msg;

	print "
Usage: $*PROGRAM-NAME
   --outdir /path/to/output/directory
   --indir  /path/to/source/of/pages
";

	exit;
}
# vim: ft=perl6
# vim:noexpandtab
