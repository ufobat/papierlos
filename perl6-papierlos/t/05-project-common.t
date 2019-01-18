use v6.c;
use Test;
use Temp::Path;

use App::Papierlos::Resources;
use App::Papierlos::Project::Common;

my $pdf = make-temp-path;
my $jpg = make-temp-path;

diag $jpg;
copy(get-resource('DEMO-PDF-Datei.pdf'), $pdf, :createonly);

ok $pdf.e, 'got a pdf';
ok !$jpg.e, 'got no jpg';
lives-ok {
    generate-preview("test preview", $pdf, $jpg);
}
ok $jpg.e, 'got a jpg';;
ok $jpg.s > 0, 'that contains content';

done-testing;
