use v6;

use lib 'lib';

use Perl6::Maven;


multi MAIN(
	Str  :$source!,
	Str  :$meta!,
	) {

	my $pm = Perl6::Maven.new( source => $source, meta => $meta );
	$pm.run;
}


