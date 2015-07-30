unit class Perl6::Maven::Atom::Author;

has $.name;
has $.email;

method Str() {
	die "No title" if not $.name;

	my $xml = '';
	#$xml ~= qq[<entry xmlns="http://purl.org/atom/ns#">\n];
	$xml ~= qq[<author>\n];
	$xml ~= qq[  <name>{$.name}</name>\n];
	$xml ~= qq[  <email>{$.email}</email>\n] if $.email;
	$xml ~= qq[</author>\n];
	return $xml;
}

# vim: ft=perl6
# vim:noexpandtab

