use v6.d;
use Test;
use Cro;

use App::Papierlos::Cro::Routes;
use App::Papierlos::IoC;

sub body-text(Cro::HTTP::Response $r) {
    $r.body-byte-stream.list.map(*.decode('utf-8')).join
}

my $app = $Container.resolve('cro-routes').get-routes;

my $source = Supplier.new;
my $responses = $app.transformer($source.Supply).Channel;

$source.emit(Cro::HTTP::Request.new(:method<GET>, :target</>));
given $responses.receive -> $r {
   is $r.status, 200, 'Got 200 response';
   is $r.header('Content-type'), 'text/html', 'Got expected header';
   like body-text($r), rx/ '<' /, 'Got expected body';
}

$source.emit(Cro::HTTP::Request.new(:method<GET>, :target</js/about.js>));
given $responses.receive -> $r {
   is $r.status, 200, 'Got 200 response';
   is $r.header('Content-type'), 'application/javascript', 'Got expected header';
   ok body-text($r).chars > 0, 'got some sourcecode';
}

$source.emit(Cro::HTTP::Request.new(:method<GET>, :target</api>));
given $responses.receive -> $r {
   is $r.status, 200, 'Got 200 response';
   is $r.header('Content-type'), 'text/plain; charset=utf-8', 'Got expected header';
   is body-text($r), 'this is a test', 'demo api is working';
}


done-testing;
