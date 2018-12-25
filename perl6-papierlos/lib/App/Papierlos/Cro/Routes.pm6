use v6.c;
use StrictClass;

unit class App::Papierlos::Cro::Routes does StrictClass;
use Cro::HTTP::Router;
use Cro::HTTP::MimeTypes;

method get-routes(--> Cro::HTTP::Router::RouteSet) {
    route {
        include 'api' => get-api-routes();
        include get-resource-routes();
    }
}

my sub get-api-routes(--> Cro::HTTP::Router::RouteSet) {
    route {
        get -> 'foo' {
            content 'text/plain', 'this is a foo';
        }
        get -> {
            content 'text/plain', 'this is a test';
        }
    }
}

my sub get-resource-routes() {
    route {
        get ->  *@path {
            static-resource(|@path, :indexes(<index.html>));
        }
    }
}

# Will be part of Cro in future releases / PR was accepted.
sub static-resource(*@path, :$mime-types, :@indexes) is export {
    my $resp = $*CRO-ROUTER-RESPONSE //
    die X::Cro::HTTP::Router::OnlyInHandler.new(:what<route>);

    my $path = @path.grep(*.so).join: '/';
    my %fallback = $mime-types // {};

    sub get-mime($ext) {
        %mime{$ext} // %fallback{$ext} // 'application/octet-stream';
    }

    sub get-extension($path --> Str) {
        my $ext = ($path ~~ m/ '.' ( <-[ \. ]>+ ) $ / );
        return $ext[0].Str;
    }

    if $path and my $resource = %?RESOURCES{$path} and $resource.IO.e {
        content get-mime(get-extension($path)), slurp($resource, :bin);
    } else {
        for @indexes {
            my $index = ($path, $_).grep(*.so).join: '/';
            my $resource = %?RESOURCES{$index};
            if $resource.IO.e {
                content get-mime(get-extension($index)), slurp($resource, :bin);
                last;
            }
        }
    }

    $resp.status //= 404;
}

