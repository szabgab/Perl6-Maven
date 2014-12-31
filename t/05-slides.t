use v6;
use Test;

plan 1;

use Perl6::Maven::Slides;
use Perl6::Maven::Authors;
use Perl6::Maven::Tools;

my $source_dir = 't/files';
read_config($source_dir);

my $authors = Perl6::Maven::Authors.new( source_dir => $source_dir);
$authors.read_authors;

my $slides = Perl6::Maven::Slides.new(source_dir => "$source_dir/pages/tutorial", authors => $authors.authors, outdir => 'tutorial/', include => $source_dir);
$slides.read_yml;

is_deeply $slides.slides, {
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

