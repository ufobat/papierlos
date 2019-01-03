use v6.c;
use Test;
use App::Papierlos::IoC;
use App::Papierlos::Unprocessed;
use App::Papierlos::Cro::Routes;
use App::Papierlos::Cro::Runner;
use Cro::HTTP::Router;

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
    App::Papierlos::DataStore,
    'resolved unprocessed-store',
);

isa-ok(
    $Container.resolve('unprocessed'),
    App::Papierlos::Unprocessed,
    'resolved unprocessed',
);

# isa-ok(
#     $Container.resolve('project-base-dirs'),
#     Seq,
#     'resolved project-base-dirs',
# );

isa-ok(
    $Container.resolve('projects'),
    App::Papierlos::Projects,
    'resolved projects',
);

isa-ok(
    $Container.resolve('cro-routes'),
    App::Papierlos::Cro::Routes,
    'resolved cro-routes'
);

isa-ok(
    $Container.resolve('cro-app-runner'),
    App::Papierlos::Cro::Runner,
    'resolved cro-app-runner'
);

done-testing;
