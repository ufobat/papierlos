use v6.c;
use StrictClass;
use Cro::Service;
use Cro::HTTP::Server;
use App::Papierlos::Cro::Routes;

unit class App::Papierlos::Cro::Runner does StrictClass;

has Int $.port = 2314;
has Str $.host = 'localhost';
has App::Papierlos::Cro::Routes $.routes is required;

method run() {
    # Create the HTTP service object
    say "running cro on $.host:$.port";
    my $application = $.routes.get-routes();
    my Cro::Service $service = Cro::HTTP::Server.new(
        :$.host, :$.port, :$application
    );

    # Run it
    $service.start;

    # Cleanly shut down on Ctrl-C
    react whenever signal(SIGINT) {
        $service.stop;
        exit;
    }
}



