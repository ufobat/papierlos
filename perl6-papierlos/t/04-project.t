use v6;
use Test;
use File::Temp;

use App::Papierlos::Project;
use App::Papierlos::Resources;

# create one file
# should be unlinked by default when programm exists.
my $tempdir = tempdir();
my $pdf-dir = $tempdir.IO.add('2019/deutsch/der igel');
my $pdf-file = $pdf-dir.add('der igel.pdf');
diag $pdf-dir.perl;
diag $pdf-file.perl;

$pdf-dir.mkdir();
$pdf-file.spurt( get-resource('DEMO-PDF-Datei.pdf').slurp(:bin) );
ok $pdf-file.e, 'der igel.pdf was created';

my $project = App::Papierlos::Project.new(
    :name<test-project>,
    :base-path( $tempdir.IO ),
    :subdir-structure<jahr fach>,
);

my (@all, @id);
@all = $project.get-all();
diag @all;
diag "----";

my @contents = eager $project.list-contents: ('2019', 'deutsch', 'der igel');
diag @contents;
diag '----';

@all = $project.get-all: ('2019', 'deutsch', 'der igel');
diag @all;

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