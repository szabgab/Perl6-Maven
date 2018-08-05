use v6;
use Test;
use LWP::Simple;
use JSON::Tiny;

plan 5;

my $dir = '/tmp/perl6_maven_' ~ time;
note("# $dir");
mkdir $dir;

run 'perl6', '-Ilib', 'script/generate.p6', '--indir=t/files', "--outdir=$dir";

note('# Check if the right files were generated');

{
	my $data = from-json "$dir/archive.json".IO.slurp;
	is-deeply $data, [
		{:date("2012-07-04"), :title("One"), :url("one")},
		{:date("2012-01-01"), :title("Hello World - scalar variables"), :url("tutorial/perl6-hello-world-scalar")},
		{:date("2012-01-01"), :title("Other resources"), :url("tutorial/perl6-other-resources")},
		{:date("2012-01-01"), :title("Getting started"), :url("tutorial/perl6-getting-started")}
	], 'archive.json'; 
}

{
	my $data = from-json "$dir/index.json".IO.slurp;
	is-deeply $data, {
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
		:unique($[[{:title("One"), :url("/one")},],])
	}, 'index.json';
}

{
	my $data = from-json "$dir/main.json".IO.slurp;
	is-deeply $data, $[{
		:abstract("<p>\nHow to get rid of duplicate values in an array in Perl 6?\n<p>\n"),
		:archive("1"),
		:author("szabgab"),
		:author_img("szabgab.png"),
		:author_name("Gabor Szabo"),
		:comments("1"),
		:content("<p>\n<p>\n<h2>Arrays with unique values</h2>\n<p>\nBasically they show various ways how one can take a list\nof values and return a sublist of the same values\nafter eliminating the duplicates.\n<p>\nWith Perl 6 its quite easy to eliminate duplicate values from a list as there\nis a built-in called <span class=\"label\">uniq</span> that will do the job.\n<p>\n<pre>\nuse v6;\n\nmy \@duplicates = (1, 1, 2, 5, 1, 4, 3, 2, 1);\nsay \@duplicates.perl;           # Array.new(1, 1, 2, 5, 1, 4, 3, 2, 1)\n</pre>\n"),
		:date("2012-07-04"),
		:google_profile_link("https://plus.google.com/102810219707784087582"),
		:keywords($["arrays", "uniq", "unique"]),
		:kw($[{
			:keyword("arrays"),
			:title("One"),
			:url("http://perl6maven.com/one")
			},
			{:keyword("uniq"), :title("One"), :url("http://perl6maven.com/one")},
			{:keyword("unique"), :title("One"), :url("http://perl6maven.com/one")}]),
		:perl5title("Unique values in an array in Perl 5"),
		:perl5url("http://szabgab.com/unique-values-in-an-array-in-perl.html"),
		:permalink("http://perl6maven.com/one"),
		:show_index_button(1),
		:status("show"),
		:timestamp("2012-07-04T16:52:02"),
		:title("One"),
		:url("one")},
	], 'main.json';
}

{
	my $data = from-json "$dir/tutorial/slides.json".IO.slurp;
	ok $data == {
		:perl6-introduction(${
			:next_file("tutorial/perl6-getting-started"),
			:next_title("Getting started"),
			:pages($[{
				:id("perl6-getting-started"),
				:prev_file("tutorial/perl6-introduction"),
				:prev_title("title Introduction to Perl 6"),
				:show_toc_button(1),
				:title("Getting started")
			},
			{
				:id("perl6-other-resources"),
				:prev_file("tutorial/perl6-getting-started"),
				:prev_title("Getting started"),
				:show_toc_button(1),
				:title("Other resources")
			}]),
			:prev_file("tutorial/perl6-hello-world-scalar"),
			:prev_title("Hello World - scalar variables"),
			:title("title Introduction to Perl 6")
		}),
		:perl6-scalars(${
			:next_file("tutorial/perl6-hello-world-scalar"),
			:next_title("Hello World - scalar variables"),
			:pages($[{:id("perl6-hello-world-scalar"),
				:prev_file("tutorial/perl6-scalars"),
				:prev_title("First steps in Perl 6"),
				:show_toc_button(1),
				:title("Hello World - scalar variables")},
			]),
			:prev_file(""),
			:prev_title(""),
			:title("First steps in Perl 6")
		})
	}, 'tutorial/slides.json';
}

{
	my $data = from-json "$dir/tutorial/lookup.json".IO.slurp;
	is-deeply $data, {
		:one(${:next_file(Any), :next_title(Any), :prev_file(Any), :prev_title(Any), :title("One")}),
		"tutorial/perl6-getting-started" => ${
			:next_file("tutorial/perl6-other-resources"),
			:next_title("Other resources"),
			:prev_file("tutorial/perl6-introduction"),
			:prev_title("title Introduction to Perl 6"),
			:title("Getting started")
		},
		"tutorial/perl6-hello-world-scalar" => ${
			:next_file("tutorial/perl6-introduction"),
			:next_title("title Introduction to Perl 6"),
			:prev_file("tutorial/perl6-scalars"),
			:prev_title("First steps in Perl 6"),
			:title("Hello World - scalar variables")
		},
		"tutorial/perl6-other-resources" => ${
			:next_file(Any),
			:next_title(Any),
			:prev_file("tutorial/perl6-getting-started"),
			:prev_title("Getting started"),
			:title("Other resources")
		}
	}, 'tutorial/lookup.json';
}

# TODO: "$dir/atom"  # atom feed
# TODO: "$dir/sitemap.xml"  # sitemap.xml


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

done-testing;
