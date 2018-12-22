#!/usr/bin/env perl6
use v6.c;

my $cwd = $?FILE.IO.resolve.parent;

say "Bulding web-papierlos";
my $web-papierlos = $cwd.parent.add('web-papierlos');
die "$web-papierlos does not exist" unless $web-papierlos.e;
run 'npm', 'run', 'build', :cwd($web-papierlos);


say "Copying web-papierlos artefacts to perl6-papierlos";
my $perl6-papierlos = $cwd;
my $dist-dir = $web-papierlos.add('dist') ~ '/*';
my $resources-dir = $perl6-papierlos.add('resources');
my $command = 'cp -vr ' ~  $dist-dir ~ ' ' ~ $resources-dir;
shell $command;

