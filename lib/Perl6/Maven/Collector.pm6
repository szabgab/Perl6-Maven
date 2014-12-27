class Perl6::Maven::Collector;

use Perl6::Maven::Tools;
use Perl6::Maven::Atom;

use JSON::Tiny;

my @pages;
my %.indexes;
my $FRONT_PAGE_LIMIT = 4;  # TODO move to config


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

method create_archive() {
	my @p = @pages.grep({ $_.<archive> }).sort({ $^b<timestamp> cmp %$^a<timestamp> });
	process_template('archive.tmpl', 'archive', { title => 'Archives', pages => @p.item });
}

method create_main() {
	my @front;
	my $count;
	for @pages -> $p {
		next if not $p<archive>;
		next if %$p<abstract> eq '';
		$count++;
		@front.push($p);
		last if $count >= $FRONT_PAGE_LIMIT;
	}

	my %params = (
		title => 'Perl 6 Maven',
		pages => @front.item,
	);
	process_template('main.tmpl', 'main', %params);
	return;
}

method create_atom_feed() {
	my ($latest) = @pages.sort({ %$^a<timestamp> cmp %$^b<timestamp> });

	my $url = config<url>;
	my $atom = Perl6::Maven::Atom.new(
		title    => config<site_title>,
		id       => "$url/",
		self     => "$url/atom",
		updated  => %$latest<timestamp>,
	);

#		author   => {
#			name  => 'Gabor Szabo',
#			email => 'gabor@szabgab.com',
#		},

	my $count;
	for @pages -> $p {
		next if not $p<archive>;
		next if %$p<abstract> eq '';
		$count++;
		my $entry = Perl6::Maven::Atom::Entry.new(
			title   => %$p<title>,
			issued  => %$p<timestamp>,
			created => %$p<timestamp>,
			#modified => %$p<timestamp>,
			link    => "$url/{%$p<url>}",
			#id      => ,   # urn:example-com:myblog:1
			summary => %$p<abstract>,
			author => Perl6::Maven::Atom::Author.new(
				#name => %.authors{ %$p<author> }<author_name>.
				name => %$p<author>,
				#email => '',
			),
		);
		$atom.entries.push($entry);
		last if $count >= 10;
	}
	return $atom.Str;
}



# vim: ft=perl6
# vim:noexpandtab
