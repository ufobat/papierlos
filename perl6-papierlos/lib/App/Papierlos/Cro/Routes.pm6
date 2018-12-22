use v6.c;

unit module App::Papierlos::Cro::Routes;
use Cro::HTTP::Router;
use Cro::HTTP::MimeTypes;

our sub get-routes(--> Cro::HTTP::Router::RouteSet) is export {
    route {
        include 'api' => get-api-routes();
        include get-resource-routes();
    }
}

sub get-api-routes(--> Cro::HTTP::Router::RouteSet) {
    route {
        get -> 'foo' {
            content 'text/plain', 'this is a foo';
        }
        get -> {
            content 'text/plain', 'this is a test';
        }
    }
}

our sub get-resource-routes() {
    route {
        get -> {
            redirect :permanent, '/static';
        }
        get ->  *@path {
            say "calling on { @path }";
            static-resource(|@path, :indexes(<index.html>));
        }
    }
}

# 04Y263
# 04Y2928 125
# www.de.eetgroup.com

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

