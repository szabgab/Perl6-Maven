class Perl6::Maven::Pages;

use Perl6::Maven::Tools;
use Perl6::Maven::Collector;


has $.source_dir;
has %.authors;
has $.outdir;
has $.include;


method save_pages() {
	debug("save pages");
	for Perl6::Maven::Collector.get_pages -> $p {
		process_template('page.tmpl', $p<url>, $p);
	}

	return;
}

method read_pages() {
	my %index;

	my $in_abstract = 0;

	my @files = dir("$.source_dir").map({ $_.basename });
	
	debug('process pages of ' ~ @files.elems ~ ' files: ' ~ @files.perl);

	for @files -> $source_file {
		if substr($source_file, *-4) ne '.txt' {
			debug("Skipping '$source_file' it does not end with .txt");
			next;
		}
		debug("Source file $source_file");

		my $fh = open "$.source_dir/$source_file", :r;
		my %params = (
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
					when 'archive' {
						%params<archive> = $value.Str;
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
						die "Invalid field '$field' in '$source_file'";
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

			if $row ~~ m/^\<include<space>file\=\"(<-["]>*)\"<space>\/\><space>*/ {
				my $file = $/[0];
				debug("including '$file' from '$.include' for '$source_file'");
				my $code = slurp("$.include$file");
				$code.=subst(/\</, '&lt;', :g);
				$row = '<b>' ~ $file ~ "</b>\n<pre>\n" ~ $code ~ "</pre>\n";
			}

			$row ~~ s:g/\<hl\>/<span class="label">/;
			$row ~~ s:g/\<\/hl\>/<\/span>/;
			if ($in_abstract) {
				%params<abstract> ~= "$row\n";
				next;
			}
			%params<content> ~= "$row\n";
		}
		#die "No keywords found in $source_file" if not %params<keywords>;

		my $outfile = substr($source_file, 0, chars($source_file) - 4);
		%params<permalink> = "{config<url>}/$.outdir$outfile";

		# TODO how do I iterate over the array elents other than this work-around?
		for 0 .. %params<keywords>.elems -1  -> $i {
			my $k = %params<keywords>[$i];
			next if $k ~~ /^<space>*$/;
			%params<kw>.push({ keyword => $k, url => %params<permalink> , title => %params<title> });
		}

		%params<url> = "$.outdir$outfile";
		if not %params<status> {
			debug("Skipping. No status in '$source_file'");
			next;
		}
		if %params<status> ne 'show' {
			debug("Skipping Status is '%params<status>' in '$source_file'");
			next;
		}

		Perl6::Maven::Collector.add_page(%params);
		# TODO how do I iterate over the array elents other than this work-around?
		for 0 .. %params<keywords>.elems -1  -> $i {
			my $k = %params<keywords>[$i];
			%index{$k}.push({ url => "/%params<url>" , title => %params<title> });
		}
	}

	Perl6::Maven::Collector.add_index(%index);
	return;
}

# vim: ft=perl6
# vim:noexpandtab
