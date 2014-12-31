use v6;
use Test;

plan 12;

use Perl6::Maven::Pages;
use Perl6::Maven::Authors;
use Perl6::Maven::Tools;

my $source_dir = 't/files';

read_config($source_dir);
is_deeply config, {"site_title" => "Perl 6 Maven", "front_page_limit" => "5", "comments" => "1", "url" => "http://perl6maven.com", "archive" => "0"}, 'config';

my $authors = Perl6::Maven::Authors.new( source_dir => $source_dir);
$authors.read_authors;
#diag $p.authors<szabgab>.keys;
is_deeply $authors.authors, {
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
isa_ok $p, 'Perl6::Maven::Pages';

$p.read_pages;

my $pages = Perl6::Maven::Collector.get_pages;
#diag @pages.perl;
is_deeply $pages[0].keys.sort,
    ("abstract",  "archive", "author", "author_img", "author_name", "comments", "content", "date", "google_profile_link",
    "keywords", "kw", "perl5title", "perl5url", "permalink", "show_index_button", "status", "timestamp", "title", "url"), 'keys';

is $pages[0]<title>, 'One', 'title';
is $pages[0]<timestamp>, '2012-07-04T16:52:02', 'timestamp';
is $pages[0]<author>, 'szabgab', 'author';
is $pages[0]<status>, 'show',   'status';
is $pages[0]<url>, 'one',       'url';
is $pages[0]<permalink>, 'http://perl6maven.com/one', 'permalink';

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

is_deeply Perl6::Maven::Collector.indexes, {
    "arrays" => [{"url" => "/one", "title" => "One"}],
    "uniq" => [{"url" => "/one", "title" => "One"}],
    "unique" => [{"url" => "/one", "title" => "One"}]
}, 'indexes';

# vim: ft=perl6


