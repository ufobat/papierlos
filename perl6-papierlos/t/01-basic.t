use v6.c;
use Test;
use App::Papierlos::IoC;
use App::Papierlos::Unprocessed;

plan 4;

ok( $Container, 'found a IoC container' );

isa-ok(
    $Container.resolve('configfile'),
    IO::Path,
    'resolved configfile'
);

isa-ok(
    $Container.resolve('configuration'),
    Hash,
    'resolved configuration',
);

isa-ok(
    $Container.resolve('unprocessed-store'),
    App::Papierlos::Unprocessed,
    'resolved projects',
);

isa-ok(
    $Container.resolve('project-base-dirs'),
    Hash,
    'resolved project-stores',
);

isa-ok(
    $Container.resolve('projects'),
    App::Papierlos::Projects,
    'resolved projects',
);

done-testing;
