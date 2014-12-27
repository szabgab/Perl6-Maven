class Perl6::Maven::Pages;

use Perl6::Maven::Tools;
use Perl6::Maven::Atom;
use Perl6::Maven::Collector;

my $FRONT_PAGE_LIMIT = 4;

has $.url;
has $.source_dir;
has @.pages;
my %.authors;

method run() {
	self.read_authors;
	self.process_pages;

	save_file('atom', self.create_atom_feed);

	self.create_main;
	for @.pages -> $p {
		process_template('page.tmpl', $p<url>, $p);
	}
	process_template('archive.tmpl', 'archive', { title => 'Archives', pages => @.pages.item });

	return;
}

method process_pages() {
	my %index;
	@.pages = ();

	my $in_abstract = 0;

	my @files = rdir("$.source_dir/pages");
	#debug('process pages');

	for @files -> $tmpl {
		next if $tmpl !~~ m/\.txt$/;
		debug("Source file $tmpl");

		my $fh = open "$.source_dir/pages/$tmpl", :r;
		my %params = (
			content   => '',
			title     => '',
			timestamp => '',
			abstract  => '',
			keywords  => [],
			kw        => [],
		);
		my $in_code = 0;
		for $fh.lines -> $line {
			#debug("Line $line");
			if $line ~~ m/^\=(\w+) \s+ (.*)/ {
				my ($field, $value) = $0, $1;
				#say $field;
				#say $value;
				given $field {
					when 'title' {
						%params<title> = $value.Str;
					}
					when 'keywords' {
						%params<keywords>.push($value.Str.split(/\s*\,\s*/));
					}
					when 'timestamp' {
						%params<timestamp> = $value.Str;
						%params<date> = substr($value.Str, 0, 10);
					}
					when 'comments' {
						%params<comments> = $value.Str;
					}
					when 'status' {
						%params<status> = $value.Str;
					}
					when 'index' {
						%params<index> = $value.Str;
					}
					when 'perl5url' {
						%params<perl5url> = $value.Str;
					}
					when 'perl5title' {
						%params<perl5title> = $value.Str;
					}
					when 'author' {
						my $nickname = $value.Str;
						if %.authors{$nickname} {
							%params<author> = $nickname;
							%params<author_name> = %.authors{$nickname}<author_name>;
							%params<author_img>  = %.authors{$nickname}<author_img>;
							%params<google_profile_link>  = %.authors{$nickname}<google_profile_link>;
						} else {
							die "Author '$nickname' was not found in the authors.txt file";
						}
					}
					when 'abstract' {
						$in_abstract = $value eq 'start' ?? 1 !! 0;
					}
					default {
						die "Invalid field '$field' in '$tmpl'";
					}
				}
				next;
			}
			my $row = ($line eq '' and not $in_code) ?? '<p>' !! $line; # TODO $line is read only here
			if $row ~~ /^\<code   (\s+ lang\=\".*\")?   \>\s*$/ {
				$row = '<pre>';
				$in_code = 1;
			} elsif $row ~~ /\<\/code\>/ {
				$row = '</pre>';
				$in_code = 0;
			} elsif $in_code {
				$row ~~ s:g/\</&lt;/;
				$row ~~ s:g/\>/&gt;/;
			}

			$row ~~ s:g/\<hl\>/<span class="label">/;
			$row ~~ s:g/\<\/hl\>/<\/span>/;
			if ($in_abstract) {
				%params<abstract> ~= "$row\n";
				next;
			}
			%params<content> ~= "$row\n";
		}
		my $outfile = substr($tmpl, 0, chars($tmpl) - 4);
		%params<permalink> = "$.url/$outfile";

		# TODO how do I iterate over the array elents other than this work-around?
		for 0 .. %params<keywords>.elems -1  -> $i {
			my $k = %params<keywords>[$i];
			%params<kw>.push({ keyword => $k, url => %params<permalink> , title => %params<title> });
		}

		%params<url> = $outfile;
		if not %params<status> {
			debug("Skipping. No status in '$tmpl'");
			next;
		}
		if %params<status> ne 'show' {
			debug("Skipping Status is '%params<status>' in '$tmpl'");
			next;
		}

		@.pages.push(%params.item);
		Perl6::Maven::Collector.add_page('page', %params);
		# TODO how do I iterate over the array elents other than this work-around?
		for 0 .. %params<keywords>.elems -1  -> $i {
			my $k = %params<keywords>[$i];
			%index{$k}.push({ url => "/%params<url>" , title => %params<title> });
		}
	}
	@.pages .= sort({ $^b<timestamp> cmp %$^a<timestamp> });

	Perl6::Maven::Collector.add_index('pages', %index);
	return;
}

# $src is 'pages' or 'slides' or 'modules' or 'doc'
# In %index the keys are the indexed keywords
# The values are arrays of hashes:
#   url   => 'http://perl6maven.com/...',
#   title => 'Some text',

method create_main() {
	my @front;
	my $count;
	for @.pages -> $p {
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
	my ($latest) = @.pages.sort({ %$^a<timestamp> cmp %$^b<timestamp> });

	my $atom = Perl6::Maven::Atom.new(
		title    => 'Perl 6 Maven',
		id       => "$.url/",
		self     => "$.url/atom",
		updated  => %$latest<timestamp>,
	);

#		author   => {
#			name  => 'Gabor Szabo',
#			email => 'gabor@szabgab.com',
#		},

	my $count;
	for @.pages -> $p {
		next if not $p<index>;
		next if %$p<abstract> eq '';
		$count++;
		my $entry = Perl6::Maven::Atom::Entry.new(
			title   => %$p<title>,
			issued  => %$p<timestamp>,
			created => %$p<timestamp>,
			#modified => %$p<timestamp>,
			link    => "$.url/{%$p<url>}",
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

# TODO move authors.txt to the root of the source directory
method read_authors() {
	for open("$.source_dir/authors.txt").lines -> $line {
		my ($author, $name, $img, $google) = $line.split(/\;/);
		%.authors{$author} = {
			author_name => $name,
			author_img  => $img,
			google_profile_link => $google,
		};
	}
	return;
}

# vim: ft=perl6
# vim:noexpandtab
