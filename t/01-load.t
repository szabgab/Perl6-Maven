use v6;
use Test;

my @modules;

sub traverse($dir = 'lib') {
    my @todo = $dir.IO;
    while @todo {
        for @todo.pop.dir -> $path {
			if $path.f {
            	@modules.push: $path.Str.substr(4).subst(/\//, '::', :g).subst(/\.pm6?$/, '');
			}

            @todo.push: $path if $path.d;
        }
    }
}

traverse();

plan @modules.elems;
for @modules -> $module {
	try EVAL "use $module";
	ok !$!, $module or diag $!;
}
