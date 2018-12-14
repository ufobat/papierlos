use v6.c;

use App::Papierlos;
use Data::Dump;

my %*SUB-MAIN-OPTS = ( :named-anywhere );

multi sub MAIN() {
    run-webapp();
}

multi sub MAIN('show', 'unprocessed') {
    say Dump get-unprocessed;
}

multi sub MAIN('show', 'store') {
    say Dump get-store;
}

multi sub MAIN('dump', 'config') {
    say Dump load-config;
}

multi sub MAIN('dump', 'projects') {
    say Dump load-projects(load-config), :skip-methods;
}

multi sub MAIN('store', Str:D $filename, Str:D $new-name, *%tags) {
    store-file($filename, %tags);
}

