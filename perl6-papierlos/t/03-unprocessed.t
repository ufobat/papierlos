use v6;
use Test;
use File::Temp;

use App::Papierlos::Unprocessed;
use App::Papierlos::Resources;

# create one file
# should be unlinked by default when programm exists.
my $tempdir = tempdir();
my $file1 = $tempdir.IO.add('file1.txt');
$file1.spurt('yada yada');
ok $file1.e, 'file1.txt was created';

my $datastore = App::Papierlos::DataStore.new( :base-path( $tempdir.IO ) );
my $unprocessed = App::Papierlos::Unprocessed.new( :$datastore );

my @contents = eager $datastore.list-contents;
diag @contents;
is @contents.elems, 1, 'one item available';
isa-ok @contents[0], IO::Path, 'it is a file';
is @contents[0].s, 9, 'which is 9 bytes large';

my (@all, @id);
@all = $unprocessed.get-all();
is @all.elems, 1, 'found one item';
diag @all.perl;
@id = |@all[0]<path>;

my %details = $unprocessed.get-details(@id);
isa-ok %details, Hash, "found details for {{ @id.perl }}";
ok %details<name>:exists, 'details contain a name';
ok %details<size>:exists, 'details contain a size';
is %details<size>, 9, 'size is 9';
is %details<path>, @id, 'it is the same id';

is-deeply @all[0], %details, 'information about all contains same details';

$file1.unlink;
ok !$file1.e, 'file1.txt was removed';
my $pdf-file = $tempdir.IO.add('test.pdf');
$pdf-file.spurt( get-resource('DEMO-PDF-Datei.pdf').slurp(:bin) );
ok $pdf-file.e, 'demo pdf exists';
diag $datastore.list-contents;
@all = $unprocessed.get-all();
is @all.elems, 1, 'found one item';
@id = |@all[0]<path>;
my $image-blob = $unprocessed.get-preview(@id);
ok $image-blob.defined, 'got a preview image';

$pdf-file.unlink;
ok !$pdf-file.e, 'demo pdf was removed';

done-testing;