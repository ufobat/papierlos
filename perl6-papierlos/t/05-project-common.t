use v6.c;
use Test;
use Temp::Path;
use Subsets::IO;

use App::Papierlos::Resources;
use App::Papierlos::Project::Common;

$*OUT.out-buffer = False;

my $single-pdf   = make-temp-path :suffix<.pdf>;
my $multiple-pdf = make-temp-path :suffix<.pdf>;

copy(get-resource('DEMO-PDF-Datei.pdf'), $single-pdf, :createonly);
copy(get-resource('multiple-pdf.pdf'), $multiple-pdf, :createonly);

ok $single-pdf.e, 'got a pdf';
ok $multiple-pdf.e, 'got another pdf';


subtest {
    my @jpgs;
    my $temp-dir;

    $temp-dir = make-temp-dir;

    lives-ok {
        @jpgs = generate-preview($single-pdf, $temp-dir);
    }, 'generate-preview doesnt die';
    ok @jpgs.elems > 0, 'found previews';
    is @jpgs.elems, $temp-dir.dir.elems, 'all files are previews';

    $temp-dir = make-temp-dir;
    lives-ok {
        @jpgs = generate-preview($multiple-pdf, $temp-dir);
    }, 'generate-preview doesnt die';
    ok @jpgs.elems > 0, 'found previews';
    is @jpgs.elems, $temp-dir.dir.elems, 'all files are previews';
}, 'generate-previews';

subtest {
    my $plain-text;
    lives-ok {
        $plain-text = generate-plaintext($single-pdf);
    }, "generate-plaintext doesn't die";
    ok $plain-text, 'created a plaintext file';
    ok $plain-text.chars > 0, 'with content';

    lives-ok {
        $plain-text = generate-plaintext($multiple-pdf);
    }, "generate-plaintext doesn't die";
    ok $plain-text, 'created a plaintext file';
    ok $plain-text.chars > 0, 'with content';

}, 'generate-plaintexts';

done-testing;
