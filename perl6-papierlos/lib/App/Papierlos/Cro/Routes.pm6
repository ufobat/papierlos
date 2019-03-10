use v6.c;
use StrictClass;

unit class App::Papierlos::Cro::Routes does StrictClass;
use Cro::HTTP::Router;
use Cro::HTTP::MimeTypes;

has $.unprocessed is required;

method get-routes(--> Cro::HTTP::Router::RouteSet) {
    route {
        include 'api' => self!get-api-routes();
        include self!get-resource-routes();
    }
}

method !get-api-routes(--> Cro::HTTP::Router::RouteSet) {
    route {
        include 'unprocessed' => self!get-unprocessed-routes();
        include 'projects' => self!get-projects-routes();
        get -> {
            content 'text/plain', 'this is a test';
        }
    }
}

method !get-projects-routes() {
    route {
        get -> $name, 'structure', *@path {
        }
        get -> $name, 'pdf', *@path {
        }
        get -> $name, 'details', *@path {
        }
        get -> $name, 'preview', *@path {
        }
        post -> $name, 'search' {
            # query_string
        }
    }
}

method !get-unprocessed-routes() {
    route {
        get -> {
            content 'application/json', $.unprocessed.get-all();
        }
        get -> 'structure', *@path {
        }
        post -> 'pdf' {
            # fileupload
        }
        get -> 'pdf', *@path {
        }
        get -> 'details', *@path {
            content 'application/json', $.unprocessed.get-details(@path);
        }
        get -> 'preview', *@path {
            content 'image/jpeg', $.unprocessed.get-preview(@path);
        }
        post -> 'store', *@path {
            # returns location string header
            # with parameters:
            # 'fields' : {
            #     'key' : 'value' ...
            # }
            # 'project': $project-name
        }
    }
}

method !get-resource-routes() {
    route {
        # get -> { static-resource('index.html') }
        get -> *@path {
            static-resource(|@path, :indexes(<index.html>));
        }
    }
}
