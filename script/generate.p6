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
	Bool :$skip-pages = False,
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
	shell("cp -r files/* $outdir"); # TODO Perl based recursive copy!
	set_outdir($outdir);


	my %index;
	my $pages = Perl6::Maven::Pages.new(source_dir => "$indir/pages", authors => $authors.authors, outdir => '', include => "$indir/files/");
	$pages.read_pages;
	$pages.save_pages if not $skip-pages;

	my $slides = Perl6::Maven::Slides.new(source_dir => "$indir/pages/tutorial", authors => $authors.authors, outdir => 'tutorial/', include => "$indir/files/");
	$slides.read_yml;
	$slides.read_pages;
	$slides.update_slides;
	$slides.save_pages if not $skip-pages;
	$slides.save_indexes();

	Perl6::Maven::Collector.create_main();
	Perl6::Maven::Collector.create_index();
	Perl6::Maven::Collector.create_archive();
	save_file('atom', Perl6::Maven::Collector.create_atom_feed);
	save_file('sitemap.xml', Perl6::Maven::Collector.create_sitemap());

	Perl6::Maven::Collector.create_authors_page();
}

sub usage($msg?) {
	say $msg if $msg;

	print "
Usage: $*PROGRAM_NAME
   --outdir /path/to/output/directory
   --indir  /path/to/source/of/pages
";

	exit;
}
# vim: ft=perl6
# vim:noexpandtab
