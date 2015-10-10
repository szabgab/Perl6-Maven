use v6;
use Test;

plan 13;

use Perl6::Maven::Pages;
use Perl6::Maven::Authors;
use Perl6::Maven::Tools;

my $source_dir = 't/files';

read_config($source_dir);
is-deeply config, {"site_title" => "Perl 6 Maven", "front_page_limit" => "5", "comments" => "1", "url" => "http://perl6maven.com", "archive" => "0"}, 'config';

my $authors = Perl6::Maven::Authors.new( source_dir => $source_dir);
$authors.read_authors;
#diag $p.authors<szabgab>.keys;
is-deeply $authors.authors, {
    "szabgab" => {
        "author_name" => "Gabor Szabo",
        "author_img" => "szabgab.png",
        "google_profile_link" => "https://plus.google.com/102810219707784087582"
    },
    "moritz" => {
        "author_name" => "Moritz Lenz",
        "author_img" => "moritz.png",
        "google_profile_link" => "https://plus.google.com/100908583399472571814"
    }
}, 'authors';

my $p = Perl6::Maven::Pages.new(source_dir => "$source_dir/pages", authors => $authors.authors, outdir => '', include => "$source_dir/files/");
isa-ok $p, 'Perl6::Maven::Pages';

$p.read_pages;

my $pages = Perl6::Maven::Collector.get_pages;

my $archive = Perl6::Maven::Collector.get_archive();
#diag $archive;
my %expected_archive = "title" => "One", "date" => "2012-07-04", "url" => "one";
is-deeply $archive, [$%expected_archive];
#my $archive_json = Perl6::Maven::Collector.get_archive_json();
#diag $archive_json;


#diag @pages.perl;
is-deeply $pages[0].params.keys.sort,
    ("abstract",  "archive", "author", "author_img", "author_name", "comments", "content", "date", "google_profile_link",
    "keywords", "kw", "perl5title", "perl5url", "permalink", "show_index_button", "status", "timestamp", "title", "url"), 'keys';

is $pages[0].params<title>, 'One', 'title';
is $pages[0].params<timestamp>, '2012-07-04T16:52:02', 'timestamp';
is $pages[0].params<author>, 'szabgab', 'author';
is $pages[0].params<status>, 'show',   'status';
is $pages[0].params<url>, 'one',       'url';
is $pages[0].params<permalink>, 'http://perl6maven.com/one', 'permalink';

my $sitemap = Perl6::Maven::Collector.create_sitemap;
my $expected_sitemap = '<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://perl6maven.com/one</loc>
    <lastmod>2012-07-04</lastmod>
  </url>
</urlset>
';
is $sitemap, $expected_sitemap, 'sitemap';

is-deeply Perl6::Maven::Collector.indexes, {
    "arrays" => [{"url" => "/one", "title" => "One"}],
    "uniq" => [{"url" => "/one", "title" => "One"}],
    "unique" => [{"url" => "/one", "title" => "One"}]
}, 'indexes';

# vim: ft=perl6


