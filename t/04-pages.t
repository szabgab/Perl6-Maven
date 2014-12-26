use v6;
use Test;

plan 11;

use Perl6::Maven::Pages;

my $url = 'http://perl6maven.com';
my $source_dir = 't/files';

my $p = Perl6::Maven::Pages.new(source_dir => $source_dir, url => $url);
isa_ok $p, 'Perl6::Maven::Pages';

$p.read_authors;
#diag $p.authors<szabgab>.keys;
is_deeply $p.authors, {
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

$p.process_pages;
is_deeply $p.pages[0].keys.sort,
    ("abstract", "author", "author_img", "author_name", "comments", "content", "date", "google_profile_link", "index",
    "keywords", "kw", "perl5title", "perl5url", "permalink", "status", "timestamp", "title", "url"), 'keys';

is $p.pages[0]<title>, 'One', 'title';
is $p.pages[0]<timestamp>, '2012-07-04T16:52:02', 'timestamp';
is $p.pages[0]<author>, 'szabgab', 'author';
is $p.pages[0]<status>, 'show',   'status';
is $p.pages[0]<url>, 'one',       'url';
is $p.pages[0]<permalink>, 'http://perl6maven.com/one', 'permalink';

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
    "arrays" => [{"url" => "/one", "title" => "One", "src" => "pages"}],
    "uniq" => [{"url" => "/one", "title" => "One", "src" => "pages"}],
    "unique" => [{"url" => "/one", "title" => "One", "src" => "pages"}]
}, 'indexes';

# vim: ft=perl6


