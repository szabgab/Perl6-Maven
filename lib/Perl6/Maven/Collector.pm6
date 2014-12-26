class Perl6::Maven::Collector;

use Perl6::Maven::Tools;
use JSON::Tiny;

my @pages;
my %.indexes;


# indexes is a global hash of all the indexes
# in which we included the 'src' key mapping to the
# name of the source.
method add_index($src, %index) {
	for %index.keys.sort( { lc $_ } ) -> $k {
		my $h = %index{$k}.flat[0];
		$h{'src'} = $src;
		%.indexes{$k}.push( $h );
	}
	return;
}

method create_index() {
	return if not %.indexes;

	my @index;
	for %.indexes.keys.sort -> $k {
		@index.push({ word => $k, entries => %.indexes{$k}.item });
	}

	my %params = (
		title    => 'Perl 6 Maven Index',
		keywords => @index.item,
	);
	process_template('index.tmpl', 'index', %params);

	save_file( 'index.json',to-json(%.indexes) );
	return;
}

# for now we only push the list here but don't use
# it, later, this should be the source for the index
# and the other meta files
method add_page($src, %data) {
	@pages.push(%data.item);
}

method create_sitemap() {
	my $xml = qq{<?xml version="1.0" encoding="UTF-8"?>\n};
	$xml ~= qq{<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n};

	for @pages -> $p {
	#	say $p<title>;
		#for $p.keys -> $k {
		#    say $k;
		#}
		$xml ~= qq{  <url>\n};
		$xml ~= sprintf('    <loc>%s</loc>', $p<permalink>) ~ "\n";
		if $p<timestamp> {
			$xml ~= sprintf('    <lastmod>%s</lastmod>', $p<timestamp>.substr(0, 10) ) ~ "\n";
		}
		#$xml ~= qq{    <changefreq>monthly</changefreq>\n};
		#$xml ~= qq{    <priority>0.8</priority>\n};
		$xml ~= qq{  </url>\n};

	}
	$xml ~= qq{</urlset>\n};
	#say $xml;
	return $xml;
}

# vim: ft=perl6
# vim:noexpandtab
