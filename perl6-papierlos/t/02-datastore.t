use v6.c;
use Test;
use Temp::Path;

use App::Papierlos::DataStore;

my $base-path = make-temp-dir;
my $datastore = App::Papierlos::DataStore.new: :$base-path;

diag $base-path;
ok $base-path.e, 'temp dir was created';
ok $datastore, 'got a datastore';

# list contents without parameters
my (@content, @path, $file);
@content = $datastore.list-contents();
is @content.elems, 0, 'it is empty';

# add-content with Str
@path = <foo bar>;
$file = $datastore.add-content(@path, 'yada bar');
isa-ok $file, IO::Path, 'got a io::path';

@content = $datastore.list-contents();
is @content.elems, 1, 'contains one element';
is @content[0].basename, 'foo', 'foo element';

# add-content with IO::Path;
my $tempfile = make-temp-path :content('yada baz');
@path = <foo baz>;
$file = $datastore.add-content(@path, $tempfile);
isa-ok $file, IO::Path, 'got a io::path';

# list again
@path = ('foo');
@content = sort $datastore.list-contents(@path);
is @content.elems, 2, 'foo contains 2 elements';
is @content[0].basename, 'bar', 'bar';
is @content[1].basename, 'baz', 'baz';

# get content
my $io;
@path = <foo bar>;
$io = $datastore.get-content(@path);
ok $io, 'got data';
is $io.slurp, 'yada bar', 'got correct content';

@path = <foo baz>;
$io = $datastore.get-content(@path, :f);
ok $io, 'got data';
is $io.slurp, 'yada baz', 'got correct content';

@path = ('foo');
$io = $datastore.get-content(@path);
ok $io, "got data";
ok $io.d, 'got correct content';

dies-ok {
    $datastore.get-content(@path, :f);
}, 'dies if you ask for a file with a path of a directory';


# remove content?

done-testing;
