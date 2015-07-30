unit class Perl6::Maven::Atom::Entry;

has $.title;
has $.summary;
has $.author; # isa Perl6::Maven::Atom::Author;
has $.issued;
has $.created;
has $.modified;
has $.link;
has $.id;
has $.content;

# valid time formats:
# 2002-10-02T10:00:00-05:00
# 2002-10-02T15:00:00Z
# 2002-10-02T15:00:00.05Z


method Str() {
	die "No title" if not $.title;
	die "No link"  if not $.link;

	my $xml = '';
	#$xml ~= qq[<entry xmlns="http://purl.org/atom/ns#">\n];
	$xml ~= qq[<entry>\n];
	$xml ~= qq[  <title>{$.title}</title>\n];
	$xml ~= qq[  <summary type="html"><![CDATA[{$.summary}]]></summary>\n]    if $.summary;
#	$xml ~= qq[  <issued>{$.issued}</issued>\n]       if $.issued;
	$xml ~= qq[  <updated>{$.created}Z</updated>\n]    if $.created;
#	$xml ~= qq[  <modified>{$.modified}</modified>\n] if $.modified;
	$xml ~= qq[  <link rel="alternate" type="text/html" href="{$.link}" />];
	my $id = $.id ?? $.id !! $.link;
	$xml ~= qq[  <id>{$id}</id>\n];
	$xml ~= qq[  <content type="html"><![CDATA[{$.content}]]></content>\n]    if $.content;
	$xml ~= $.author.Str if $.author;
	$xml ~= qq[</entry>\n];
	return $xml;
}

# vim: ft=perl6
# vim:noexpandtab

