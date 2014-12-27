#!/usr/bin/env perl6
use v6;

use lib 'lib';

use Perl6::Maven::Tools;
use Perl6::Maven::Pages;
use Perl6::Maven::Collector;
use Perl6::Maven::Slides;

multi MAIN(Bool :$help!) {
	say 'no param' if  not $help;
	usage();
}

multi MAIN(
	Str  :$indir   is copy,
	Str  :$outdir!,
    ) {
	usage('avoid updirs') if $outdir ~~ m/\.\./;

	# If the user tries to pass --outdir ~/tmp/perl6maven the code will receive the ~ without the shell expanding it
	# Let's avoid creating a directory called ~
	for $indir, $outdir -> $dir {
		usage("You cannot pass ~ in the path '$dir'") if $dir ~~ m/\~/;
	}

    my $url = 'http://perl6maven.com';

	mkpath $outdir;
 	shell("cp -r files/* $outdir"); # TODO Perl based recursive copy!
 	set_outdir($outdir);

	my $slides = Perl6::Maven::Slides.new(file => "$indir/pages/tutorial/pages.yml");
	$slides.read_yml;
 
 	my %index;
 	if $indir {
         my $p = Perl6::Maven::Pages.new(source_dir => $indir, url => $url);
         $p.run;
 	}

	$slides.save();


 	Perl6::Maven::Collector.create_index();
 	save_file('sitemap.xml', Perl6::Maven::Collector.create_sitemap());
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

