class Perl6::Maven::Slides;

has $.file;
has %.slides;


# AFAIK There is no real YAML reader for Perl 6 yet, so this implements the subset we use.
method read_yml() {
	# temporary hard-coding
	my $fh = open $.file, :r;
	my $id;
	for $fh.lines -> $line {
		#if $line ~~ /^\- id\: ([\w\-]+)$/ {
		if $line ~~ /^\-<space>id\:<space>(.*)/ {
			$id = "$/[0]";
			#say "Match $id";
			next;
		}

		if $line ~~ /^<space>*title\:<space>(.*)/ {
			%.slides{$id}<title> = "$/[0]";
			next;
		}
		if $line ~~ /^<space>*pages\:/ {
			next;
		}

		if $line ~~ /^<space>*\-<space>(.*)/ {
			%.slides{$id}<pages>.push({ id => "$/[0]" });
			next;
		}
	
		die "Line could not be recognized in $.file <$line>";
	}
}


