class Perl6::Maven::Collector;

use Perl6::Maven::Tools;
use Perl6::Maven::Atom;

use JSON::Tiny;

my %pages;
my %.indexes;


# indexes is a global hash of all the indexes
method add_index(%index) {
	for %index.keys.sort( { lc $_ } ) -> $k {
		my $h = %index{$k}.flat[0];
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
	save_template('index.tmpl', 'index', %params);

	save_file( 'index.json',to-json(%.indexes) );
	return;
}

# for now we only push the list here but don't use
# it, later, this should be the source for the index
# and the other meta files
method add_page($page) {
	debug("add page url: {$page.params<url>}");
	die "{$page.params<url>} already exists" if %pages{$page.params<url>};
	%pages{$page.params<url>} = $page;
}

method get_page($id) {
	return %pages{$id};
}

method get_pages() {
	return values %pages;
}

method create_sitemap() {
	my $xml = qq{<?xml version="1.0" encoding="UTF-8"?>\n};
	$xml ~= qq{<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n};

	for %pages.values -> $page {
		$xml ~= qq{  <url>\n};
		$xml ~= sprintf('    <loc>%s</loc>', $page.params<permalink>) ~ "\n";
		if $page.params<timestamp> {
			$xml ~= sprintf('    <lastmod>%s</lastmod>', $page.params<timestamp>.substr(0, 10) ) ~ "\n";
		}
		#$xml ~= qq{    <changefreq>monthly</changefreq>\n};
		#$xml ~= qq{    <priority>0.8</priority>\n};
		$xml ~= qq{  </url>\n};

	}
	$xml ~= qq{</urlset>\n};
	#say $xml;
	return $xml;
}

method archived_pages() {
	return %pages.values.grep({ $_.params<archive> }).sort({ $^b.params<timestamp> cmp $^a.params<timestamp> });
}

method create_archive() {
	my @p = self.archived_pages();
	save_template('archive.tmpl', 'archive', { title => 'Archives', pages => @p.map({ $_.params.item }).item });
}

method create_main() {
	my @front;
	my $count;
	for self.archived_pages -> $page {
		if $page.params<abstract> eq '' {
			warning("Skipping page '{$page.params<url>}' from front-page due to lack of abstract");
			next;
		}
		$count++;
		@front.push($page.params.item);
		last if $count >= config<front_page_limit>;
	}

	my %params = (
		title => config<site_title>,
		pages => @front.item,
	);
	save_template('main.tmpl', 'main', %params);
	return;
}

method create_atom_feed() {
	my @archived_pages = self.archived_pages;
	my $latest = @archived_pages[0];

	my $url = config<url>;
	my $atom = Perl6::Maven::Atom.new(
		title    => config<site_title>,
		id       => "$url/",
		self     => "$url/atom",
		updated  => $latest.params<timestamp>,
	);

#		author   => {
#			name  => 'Gabor Szabo',
#			email => 'gabor@szabgab.com',
#		},

	my $count;
	for @archived_pages -> $page {
		next if not $page.params<archive>;
		next if $page.params<abstract> eq '';
		$count++;
		my $entry = Perl6::Maven::Atom::Entry.new(
			title   => $page.params<title>,
			issued  => $page.params<timestamp>,
			created => $page.params<timestamp>,
			#modified => $page.params<timestamp>,
			link    => "$url/{$page.params<url>}",
			#id      => ,   # urn:example-com:myblog:1
			summary => $page.params<abstract>,
			author => Perl6::Maven::Atom::Author.new(
				#name => %.authors{ $pasge.params<author> }<author_name>.
				name => $page.params<author>,
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
