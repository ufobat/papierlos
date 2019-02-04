use v6;
use Test;
use Temp::Path;

use App::Papierlos::Project::Structured;
use App::Papierlos::Resources;

# create one file
# should be unlinked by default when programm exists.
my $base-path = make-temp-dir;
my $datastore = App::Papierlos::DataStore.new: :$base-path;
my $project = App::Papierlos::Project::Structured.new(
    :name<test-project>,
    :$datastore,
    :subdir-structure<jahr fach>
);

my (@all, @path, %details);

# add test data
@path = ('2019', 'deutsch', 'der igel', 'der igel.pdf');
$datastore.add-content(@path, get-resource('DEMO-PDF-Datei.pdf') );

subtest {
    @path = ();
    @all = $project.get-children(@path);
    is @all.elems, 1,  'found one item';
    %details = @all[0];
    is %details<type>, 'dir', 'it is a dir';
    is %details<name>, '2019', 'found year: 2019';

    @path = ('2019');
    @all = $project.get-children(@path);
    is @all.elems, 1,  'found one item';
    %details = @all[0];
    is %details<type>, 'dir', 'it is a dir';
    is %details<name>, 'deutsch', 'found fach: deutsch';

    @path = ('2019', 'deutsch');
    @all = $project.get-children(@path);
    is @all.elems, 1,  'found one item';
    %details = @all[0];
    is %details<type>, 'file', 'it is a file';
    is %details<name>, 'der igel', 'found pdf document: der igel';
}, 'get-children';

# maybe unlink that manually added file again.

subtest {
    @path = ('2019', 'deutsch', 'der igel');
    diag $project.get-node-details(@path);
    %details = $project.get-node-details(@path);
    is %details<type>, 'file', 'it is a file';
    is %details<name>, 'der igel', 'found pdf document: der igel';
}, 'get-node-details';

my %fields = ( :jahr(2019), :fach<HSU>, :schwierigkeit<einfach> );

subtest {
    my $pdf = get-resource('DEMO-PDF-Datei.pdf');
    $project.add-pdf('Die Bedeutung des Waldes', $pdf, :%fields );
    @path = ('2019', 'HSU', 'Die Bedeutung des Waldes');
    diag $project.get-node-details(@path);
}, 'add-pdf';

subtest {
    @path = ('2019', 'HSU', 'Die Bedeutung des Waldes');
    my @images = $project.get-preview(@path);
    ok @images.elems > 0, 'get preview images';
    diag @images;
    for @images -> $image {
        isa-ok $image, IO::Path, 'is an IO::Path';
    }
}, 'get-preview';

subtest {
    @path = ('2019', 'HSU', 'Die Bedeutung des Waldes');
    my $pdf = $project.get-pdf(@path);
    ok $pdf.defined, 'got a pdf file';
    isa-ok $pdf, IO::Path, 'is an IO::Path';
}, 'get-pdf';

subtest {
    @path = ('2019', 'HSU', 'Die Bedeutung des Waldes');
    my %got-fields = $project.get-fields(@path);
    is-deeply %got-fields, %fields, 'expected fields';
}, 'get-fields';

subtest {
    @path = ('2019', 'HSU', 'Die Bedeutung des Waldes');
    my $file = $project.get-plaintext(@path);
    ok $file.e, 'plaintext file exists';
    ok $file.s > 0, 'plaintext contains some chars';
}, 'get-plaintest';

# subtest {
#     my $project2 = App::Papierlos::Project::Structured.new(
#         :name<test2-project>,
#         datastore => App::Papierlos::DataStore.new(base-path => make-temp-dir),
#         :subdir-structure<jahr fach>
#     );

#     #$project.move(:@path, to => $project2);

# }, 'move to another project';

done-testing;
