unit class Perl6::Maven::Atom;

use Perl6::Maven::Atom::Author;
use Perl6::Maven::Atom::Entry;

has $.title;
has $.subtitle; # ?
has $.link;
has $.updated;
has $.id;
has $.self;

has @.entries; # isa Perl6::Maven::Atom::Entry;

# (see http://blogs.perl.org/atom.xml )

method Str() {
	my $xml = '';
	$xml ~= qq[<?xml version="1.0" encoding="utf-8"?>\n];
	$xml ~= qq[<feed xmlns="http://www.w3.org/2005/Atom">\n];
	$xml ~= qq[<link href="{$.self}" rel="self" />\n];
	$xml ~= qq[<title>{$.title}</title>\n];
	$xml ~= qq[<link>{$.link}</link>\n] if $.link;
	$xml ~= qq[<id>{$.id}</id>\n] if $.id;
	$xml ~= qq[<updated>{$.updated}Z</updated>\n] if $.id;
	# subtitle
	# generator
	for @.entries -> $e {
		$xml ~= $e.Str;
	}
	$xml ~= qq[</feed>\n];
	return $xml;
}


#
#
#<author>
#  <name><TMPL_VAR admin_name></name>
#  <email><TMPL_VAR admin_email></email>
#</author>
#<generator uri="http://search.cpan.org/dist/Dwimmer/" version="[% dwimmer_version %]">Dwimmer</generator>
#

# vim: ft=perl6
# vim:noexpandtab


