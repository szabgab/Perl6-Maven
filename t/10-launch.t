use v6;
use Test;
use LWP::Simple;
use JSON::Tiny;

plan 3;

my $dir = '/tmp/perl6_maven_' ~ time;
note("# $dir");
mkdir $dir;

run 'perl6', '-Ilib', 'script/generate.p6', '--indir=t/files', "--outdir=$dir";

ok 1;

note('# Check if the right files were generated');

{
	my $json = "$dir/archive.json".IO.slurp;
	my $archive = from-json $json;
	#note("# " ~ $archive.perl);
	is-deeply $archive, [
		{:date("2012-07-04"), :title("One"), :url("one")},
		{:date("2012-01-01"), :title("Hello World - scalar variables"), :url("tutorial/perl6-hello-world-scalar")},
		{:date("2012-01-01"), :title("Other resources"), :url("tutorial/perl6-other-resources")},
		{:date("2012-01-01"), :title("Getting started"), :url("tutorial/perl6-getting-started")}
	], 'archive'; 
}

{
	my $json = "$dir/index.json".IO.slurp;
	my $archive = from-json $json;
	#note("# " ~ $archive.perl);
	is-deeply $archive, {
		"\$" => $[[ {:title("Hello World - scalar variables"), :url("/tutorial/perl6-hello-world-scalar")},],], 
		:CLR($[[{:title("Getting started"), :url("/tutorial/perl6-getting-started")},],]),
		:IRC($[[{:title("Other resources"), :url("/tutorial/perl6-other-resources")},],]),
		:JVM($[[{:title("Getting started"), :url("/tutorial/perl6-getting-started")},],]),
		:MoarVM($[[{:title("Getting started"), :url("/tutorial/perl6-getting-started")},],]),
		:Niecza($[[{:title("Getting started"), :url("/tutorial/perl6-getting-started")},],]),
		:Perlito($[[{:title("Getting started"), :url("/tutorial/perl6-getting-started")},],]),
		:Pugs($[[{:title("Getting started"), :url("/tutorial/perl6-getting-started")},],]),
		:Rakudo($[[{:title("Getting started"), :url("/tutorial/perl6-getting-started")},],]),
		:arrays($[[{:title("One"), :url("/one")},],]),
	"mailing list" => $[[{:title("Other resources"), :url("/tutorial/perl6-other-resources")},],],
		:my($[[{:title("Hello World - scalar variables"), :url("/tutorial/perl6-hello-world-scalar")},],]),
		:say($[[{:title("Hello World - scalar variables"), :url("/tutorial/perl6-hello-world-scalar")},],]),
		:uniq($[[{:title("One"), :url("/one")},],]),
		:unique($[[{:title("One"), :url("/one")},],])}
}



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

