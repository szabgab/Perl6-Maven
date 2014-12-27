use v6;
use Test;

plan 1;

use Perl6::Maven::Slides;

my $s = Perl6::Maven::Slides.new(file => 't/files/pages/tutorial/pages.yml');
$s.read_yml;

is_deeply $s.slides, {
	"perl6-introduction" => {
		"title" => "title Introduction to Perl 6",
		"pages" => [
			{ id => "perl6-getting-started" },
			{ id => "perl6-other-resources" },
		],
	},
	"perl6-scalars" => {
		"title" => "First steps in Perl 6",
		"pages" => [
			{ id => "perl6-hello-world-scalar" },
		],
	}
}, 'yaml file read in';
#diag $s.slides.perl ;

