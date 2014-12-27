use v6;
use Test;

plan 1;

use Perl6::Maven::Slides;

my $s = Perl6::Maven::Slides.new(file => 't/files/pages/tutorial/pages.yml');
$s.read_yml;

is_deeply $s.slides, {
	"perl6-introduction" => {
		"pages" => ["perl6-getting-started", "perl6-other-resources"],
		"title" => "title Introduction to Perl 6"},
	"perl6-scalars" => {
		"pages" => ["perl6-hello-world-scalar"],
		"title" => "First steps in Perl 6"},
}, 'yaml file read in';
#diag $s.slides.perl ;

