use v6;
use Test;
use Temp::Path;

use App::Papierlos::Project::Flat;
use App::Papierlos::Resources;

# create one file
# should be unlinked by default when programm exists.
my $base-path = make-temp-dir;
my $datastore = App::Papierlos::DataStore.new: :$base-path;
my $unprocessed = App::Papierlos::Project::Flat.new( :$datastore );

my (@all, @path);

@path = ('file1.pdf');
$datastore.add-content(@path, 'yada yada');

subtest {
    @all = $unprocessed.get-children();
    is @all.elems, 1, 'found one item';
    @path = ('file1');
    is-deeply @all[0]<path>, @path, 'correct path';

}, 'get-children';

subtest {
    @path = ('file1');
    my %details = $unprocessed.get-node-details(@path);
    isa-ok %details, Hash, "found details for {{ @path.perl }}";
    ok %details<name>:exists, 'details contain a name';
    ok %details<size>:exists, 'details contain a size';
    is %details<size>, 9, 'size is 9';
    is %details<path>, @path, 'it is the same id';
    is-deeply @all[0], %details, 'information about all contains same details';
}, 'get-node-details';

subtest {
    lives-ok {
        $unprocessed.add-pdf('test', get-resource('DEMO-PDF-Datei.pdf'));
    }, 'added test';
    @all = $unprocessed.get-children();
    is @all.elems, 2, 'found two items';
}, 'add-pdf';

subtest {
    @path = ('test');
    my $image-blob = $unprocessed.get-preview(@path);
    ok $image-blob.defined, 'got a preview image';
}, 'get-preview';

## TODO
# get-pdf
# get-fields

done-testing;