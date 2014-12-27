class Perl6::Maven::Authors;

has $.source_dir;
has %.authors;

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

