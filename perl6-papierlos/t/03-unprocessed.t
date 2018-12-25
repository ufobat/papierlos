use v6;
use Test;
use File::Temp;

use App::Papierlos::Unprocessed;

# create one file
# should be unlinked by default when programm exists.
my $tempdir = tempdir();
$tempdir.IO.add('file1.txt').spurt('yada yada');

my $unprocessed = App::Papierlos::Unprocessed.new(
    :base-path( $tempdir.IO )
);

my @contents = eager $unprocessed.list-contents;

diag @contents;
is @contents.elems, 1, 'one item available';
isa-ok @contents[0], IO::Path, 'it is a file';
is @contents[0].s, 9, 'which is 9 bytes large';

my %all = $unprocessed.get-all();
is %all.elems, 1, 'found one item';
my $id = %all.keys[0];

my %details = $unprocessed.get-details($id);
isa-ok %details, Hash, "found details for $id";
ok %details<name>:exists, 'details contain a name';
ok %details<size>:exists, 'details contain a size';
ok %details<id>:exists, 'details contain a id';
is %details<size>, 9, 'size is 9';
is %details<id>, $id, 'it is the same id';

is-deeply %all{$id}, %details, 'information about all contains same details';

done-testing;