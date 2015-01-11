class Perl6::Maven::Page;

use Perl6::Maven::Tools;

has %.authors;
has $.outdir;
has $.include;
has %.params;

method read_file($source_file, $outfile) {
	my $fh = open $source_file, :r;
	%.params = (
		content   => '',
		title     => '',
		timestamp => '',
		abstract  => '',
		keywords  => [],
		kw        => [],
		archive   => config<archive>,
		comments  => config<comments>,
		show_index_button => 1,
	);

	my $in_abstract = False;
	my $in_code = False;
	for $fh.lines -> $line {
		#debug("Line $line");
		if $line ~~ m/^\=(\w+) \s+ (.*)/ {
			my ($field, $value) = $0, $1;
			#say $field;
			#say $value;
			given $field {
				when 'title' {
					%.params<title> = $value.Str;
				}
				when 'keywords' {
					%.params<keywords>.push($value.Str.split(/\s*\,\s*/));
				}
				when 'timestamp' {
					%.params<timestamp> = $value.Str;
					%.params<date> = substr($value.Str, 0, 10);
				}
				when 'comments' {
					%.params<comments> = $value.Str;
				}
				when 'status' {
					%.params<status> = $value.Str;
				}
				when 'archive' {
					%.params<archive> = $value.Str;
				}
				when 'perl5url' {
					%.params<perl5url> = $value.Str;
				}
				when 'perl5title' {
					%.params<perl5title> = $value.Str;
				}
				when 'author' {
					my $nickname = $value.Str;
					if %.authors{$nickname} {
						%.params<author> = $nickname;
						%.params<author_name> = %.authors{$nickname}<author_name>;
						%.params<author_img>  = %.authors{$nickname}<author_img>;
						%.params<google_profile_link>  = %.authors{$nickname}<google_profile_link>;
					} else {
						die "Author '$nickname' was not found in the authors.txt file";
					}
				}
				when 'abstract' {
					if $value eq 'start' {
						$in_abstract = True;
					} elsif $value eq 'end' {
						$in_abstract = False;
					} else {
						die "Invalid =abstract value: '$value'";
					}
				}
				default {
					die "Invalid field '$field' in '$source_file'";
				}
			}
			next;
		}
		my $row = ($line eq '' and not $in_code) ?? '<p>' !! $line; # TODO $line is read only here
		if $row ~~ /^\<code   (\s+ lang\=\".*\")?   \>\s*$/ {
			$row = '<pre>';
			$in_code = True;
		} elsif $row ~~ /\<\/code\>/ {
			$row = '</pre>';
			$in_code = False;
		} elsif $in_code {
			$row ~~ s:g/\</&lt;/;
			$row ~~ s:g/\>/&gt;/;
		}

		if $row ~~ m/^\<include<space>file\=\"(<-["]>*)\"<space>\/\><space>*/ {
			my $file = $/[0];
			debug("including '$file' from '$.include' for '$source_file'");
			my $code = slurp("$.include$file");
			$code.=subst(/\</, '&lt;', :g);
			$row = '<b>' ~ $file ~ "</b>\n<pre>\n" ~ $code ~ "</pre>\n";
		}

		$row ~~ s:g/\<hl\>/<span class="label">/;
		$row ~~ s:g/\<\/hl\>/<\/span>/;
		if $in_abstract {
			%.params<abstract> ~= "$row\n";
			next;
		}
		%.params<content> ~= "$row\n";
	}
	if $in_abstract {
		die 'Abstract has not ended';
	}
	if $in_code {
		die 'Code has not ended';
	}
	#die "No keywords found in $source_file" if not %.params<keywords>;

	%.params<permalink> = "{config<url>}/$.outdir$outfile";
	%.params<url> = "$.outdir$outfile";

	# TODO how do I iterate over the array elents other than this work-around?
	for 0 .. %.params<keywords>.elems -1  -> $i {
		my $k = %.params<keywords>[$i];
		next if $k ~~ /^<space>*$/;
		%.params<kw>.push({ keyword => $k, url => %.params<permalink> , title => %.params<title> });
	}

	return;
}

method generate {
	process_template('page.tmpl', %.params);
}




