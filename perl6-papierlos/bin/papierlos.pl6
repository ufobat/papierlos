use v6.c;

use App::Papierlos::IoC;
use Data::Dump;

my %*SUB-MAIN-OPTS = ( :named-anywhere );

multi sub MAIN() {
    my $cro-app = $Container.resolve('cro-app-runner');
    $cro-app.run;
}

multi sub MAIN('show', 'unprocessed') {
    say Dump $Container.resolve('unprocessed-store');
}

multi sub MAIN('dump', 'config') {
    say Dump $Container.resolve('configuration');
}

multi sub MAIN('dump', 'projects') {
    say Dump $Container.resolve('projects'), :skip-methods;
}

# multi sub MAIN('store', Str:D $filename, Str:D $new-name, *%tags) {
#     store-file($filename, %tags);
# }

