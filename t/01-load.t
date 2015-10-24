use v6;
use Test;
use lib 'lib';

my @modules;

sub traverse($dir = 'lib') {
    my @todo = $dir.IO;
    while @todo {
        for @todo.pop.dir -> $path {
			if $path.f and $path.Str ~~ /\.pm6$/ {
            	@modules.push: $path.Str.substr(4).subst(/\//, '::', :g).subst(/\.pm6?$/, '');
			}

            @todo.push: $path if $path.d;
        }
    }
}

traverse();

plan @modules.elems;
for @modules -> $module {
	note("# $module");
	try EVAL "use $module";
	ok !$!, $module or diag $!;
}
