use v6.c;

use App::Papierlos::DataSource;
use App::Papierlos::DataStore;
use App::Papierlos::Unprocessed;

use StrictClass;

class App::Papierlos::Projects does StrictClass {
    has %.projects is required;

    method store-file(
        IO::Path:D $sourcefile,
        Str:D $project-name,
        Str:D %tags,
        Str:D :$new-name,
    ) {
        unless %.projects{$project-name}:exists {
            die "project $project-name does not exist";
        }

        my $project = %.projects{$project-name};
        $project.store-file($sourcefile, %tags, :$new-name);
    }
}

