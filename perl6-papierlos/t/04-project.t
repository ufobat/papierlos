use v6;
use Test;
use Temp::Path;

use App::Papierlos::Project;
use App::Papierlos::Resources;

# create one file
# should be unlinked by default when programm exists.
my $base-path = make-temp-dir;
my $datastore = App::Papierlos::DataStore.new: :$base-path;
my $project = App::Papierlos::Project.new(
    :name<test-project>,
    :$datastore,
    :subdir-structure<jahr fach>
);

my (@all, @path, %details);

@path = ('2019', 'deutsch', 'der igel', 'der igel.pdf');
$datastore.add-content(@path, get-resource('DEMO-PDF-Datei.pdf') );

@all = $project.get-all();
is @all.elems, 1,  'found one item - dir';
%details = @all[0];
is %details<type>, 'dir', 'it is a dir';

# test details??
# %details = $project.get-details(@path);

@path.pop; # remove file from @path

@all = $project.get-all: @path;
is @all.elems, 1, 'found one item - file';
%details = @all[0];
is %details<type>, 'file', 'it is a file';

# %details = $project.get-details(@path);

done-testing;

=finish

my @contents = eager $unprocessed.list-contents;

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
diag $unprocessed.list-contents;
@all = $unprocessed.get-all();
is @all.elems, 1, 'found one item';
@id = |@all[0]<path>;
my $image-blob = $unprocessed.get-preview(@id);
ok $image-blob.defined, 'got a preview image';

$pdf-file.unlink;
ok !$pdf-file.e, 'demo pdf was removed';

done-testing;