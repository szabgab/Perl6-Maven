unit class Perl6::Maven::Collector;

use Perl6::Maven::Tools;
use Perl6::Maven::Atom;

use JSON::Tiny;

my %pages;
my %.indexes;


# indexes is a global hash of all the indexes
method add_index(%index) {
	for %index.keys.sort( { lc $_ } ) -> $k {
		if (not %.indexes{$k}:exists) {
			%.indexes{$k} = [];
		}
		my %h = %index{$k};
		%.indexes{$k}.push: %h;
	}
	return;
}

method get_index_json() {
	return if not %.indexes;
	return to-json(%.indexes);
}

method create_index_page( $json ) {
	my $indexes = from-json($json);
	my @index;
	for $indexes.keys.sort -> $k {
		@index.push({ word => $k, entries => $indexes{$k}.item });
	}

	my %params = (
		title    => config<site_title> ~ ' Index',
		keywords => @index.item,
	);
	return process_template('index.tmpl', %params);
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

method get_lookup_json() {
	my %lookup;
	for %pages.keys -> $k {
		for <title prev_file prev_title next_file next_title> -> $field {
			%lookup{$k}{$field} = %pages{$k}.params{$field};
		}
	}
	return to-json %lookup.item;
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

method get_archive() {
	my @p = self.archived_pages();
	my @data;
	for @p -> $e {
		@data.push: ${
			url => $e.params<url>,
			title => $e.params<title>,
			date => $e.params<date>,
		};
	}
	return @data.item;
}

method get_archive_json() {
	return to-json( self.get_archive() );
}

method create_archive_page($json) {
	process_template('archive.tmpl', { title => 'Archives', pages => from-json($json) });
}

method create_main_page($json) {
	my $front = from-json ($json);
	my %params = (
		title => config<site_title>,
		pages => $front,
	);
	return process_template('main.tmpl', %params);
}

method get_main_json() {
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
	return to-json( @front.item );
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

method create_toc_page($json) {
	my $slides = from-json $json;

	my @chapters;
	for $slides.keys -> $id {
		$slides{$id}<content> //= '';
		$slides{$id}<id> = $id;
		@chapters.push($slides{$id});
	}

	my %data = (
		title => "The Perl Maven's Perl 6 Tutorial",
		chapters => @chapters.item,
		content => ''
	);

	return process_template('slides_toc.tmpl', %data);
}

method create_chapters_page($data) {
	$data<content> //= '';
	return process_template('slides_chapter.tmpl', $data);
}




# vim: ft=perl6
# vim:noexpandtab
