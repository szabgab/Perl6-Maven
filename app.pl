use v6;

use lib 'lib';

use Perl6::Maven;


multi MAIN(
	Str  :$source!,
	Str  :$meta!,
	Int  :$limit = 1,
	) {

	my $pm = Perl6::Maven.new( source => $source, meta => $meta, limit => $limit );
	$pm.run;
}


