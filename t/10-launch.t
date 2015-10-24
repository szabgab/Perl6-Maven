use v6;
use Test;
use LWP::Simple;

plan 1;

my $dir = '/tmp/perl6_maven_' ~ time;
note("# $dir");
mkdir $dir;

run 'perl6', '-Ilib', 'script/generate.p6', '--indir=t/files', "--outdir=$dir";

ok 1;


# note "# Launching app";
# #run 'perl6', '-Ilib', 'app.pl', '--source=/home/gabor/work/perl6maven.com/', '--meta=/home/gabor/work/perl6maven-live.com/';
# run './TEST';
# sleep 10;
# 
# my $url = 'http://127.0.0.1:3000';
# 
# {
# 	my $html = LWP::Simple.get("$url/");
# 	like $html, rx/Perl ' ' 6 ' ' Maven/;
# 	ok $html.index('<h1>Perl 6 Maven</h1>');
# }
# 
# {
# 	my $html = LWP::Simple.get("$url/archive");
# 	ok $html.index('<h1>Perl 6 Maven Archive</h1>');
# }

