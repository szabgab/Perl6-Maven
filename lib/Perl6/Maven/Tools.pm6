module Perl6::Maven::Tools;

use Template::Mojo;
 
my $SEPARATOR = '/'; # TODO should be OS dependent

my %config;
 
my $outdir;
sub set_outdir($d) is export {
	$outdir = $d;
}

sub debug is export {
	say 'DEBUG: ', @_; # if $*ENV<DEBUG>;
}

sub rdir($path) is export {
	my @things = dir($path).map({ $_.basename });
	my @files = @things.grep({ "$path/$_".IO.f });
	for @things.grep({ "$path/$_".IO.d }) -> $d {
		@files.push( rdir("$path/$d").map({ "$d/$_" }) );
	}
	return @files;
}


sub process_template($template, $outfile, %params) is export {
	%params<site_title> = %config<site_title>;

	%params<description> //= '';
	%params<author> //= '';

	debug("processing template $template to $outfile");
	my $fh = open "templates/$template", :r;
	my $tmpl = $fh.slurp-rest;
	my $output = Template::Mojo.new($tmpl).render(%params);

	save_file($outfile, $output);
	return;
}

sub save_file($outfile, $content) is export {
	debug("save_file $outfile");
	my $file = "$outdir/" ~ $outfile;
	mkpath dirname $file;
	my $out = open $file, :w;
	$out.print($content);
	$out.close; # TODO without calling close the file remained empty
	return;
}

# TODO isn't this implemented already?
# if not, improve it to make it OS independent
sub basename($path) is export {
	return (split $SEPARATOR, $path)[*-1];
}
sub dirname($path) is export {
	my $basename = basename($path);
	return substr($path, 0, chars($path) - chars($basename) - chars($SEPARATOR));
}
# TODO maybe mkdir can get parameters? (in Shell::Commands ?)
sub mkpath($path) is export {
	my @dirs = split  $SEPARATOR, $path;
	@dirs.shift if @dirs[0] eq '';
	my $p = '';
	for @dirs -> $d {
		$p ~= $SEPARATOR ~ $d;
		if $p.IO !~~ :e {
			mkdir $p;
		}
	}
}

sub tree($dir) is export {
	return if $dir.IO !~~ :d;
	my @things = dir($dir);

	my @files;

	for @things -> $thing {
		my $path = "$dir/$thing";
		push @files, $path;
		try {
			push @files, tree($path);

			CATCH {
				when X::IO::Dir {
					#say "skipping $path - not a tree";
				}
			}
		}
	}
	return @files;
}

sub read_config($dir) is export {
	my $fh = open "$dir/config.ini", :r;
	for $fh.lines -> $line {
		my ($key, $value) = $line.split(':');
		%config{$key} = $value;
	}
	#debug(%config.perl);
}

sub config() is export {
	return %config;
}


# vim: ft=perl6
# vim:noexpandtab

