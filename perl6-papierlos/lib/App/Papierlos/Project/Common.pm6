use v6.c;
use Temp::Path;
use Subsets::IO;
use Shell::Command;

unit module App::Papierlos::Project::Common;

my $convert    = BEGIN $*DISTRO.is-win ?? 'convert.exe'   !! 'convert';
my $tesseract  = BEGIN $*DISTRO.is-win ?? 'tesseract.exe' !! 'tesseract';
my $pdftotext  = BEGIN $*DISTRO.is-win ?? 'pdftotext.exe' !! 'pdftotext';

sub generate-preview(IO::Path::e $pdf, IO::Path::d $dir = $pdf.parent --> Seq) is export {
    my $dstname = $pdf.basename ~ '_%0d.jpg';
    die unless $dir.d;
    my $dst = $dir.add($dstname).absolute;
    my @convert-command = ($convert, $pdf.absolute, $dst);
    run-command(@convert-command, :out, :err);
    return list-preview($dir, $pdf.basename);
}

sub generate-plaintext(IO::Path::e $pdf, Str :$lang --> Str) is export {
    my $tiff = generate-large-tiff($pdf);
    #return "done";
    return ocr-large-tiff($tiff, :$lang);
}

sub list-preview(IO::Path::d $dir, Str $basename --> Seq) is export {
    return $dir.dir: test => { .starts-with($basename ~ '_') and .ends-with('.jpg') };
}

sub read-plaintext(IO::Path::e $pdf --> Str) is export {
    my $plain-text-file = make-temp-path;
    my @pdftotext-command = ($pdftotext, $pdf.absolute, $plain-text-file.absolute);
    run-command(@pdftotext-command, :err, :out);
    return $plain-text-file.slurp;
}

my sub ocr-large-tiff(IO::Path::e $tiff, Str :$lang --> Str) {
    my @tess-command = ($tesseract);
    if $lang {
        die "language not supported" unless $lang ~~ any <deu eng>;
        push @tess-command, '-l', $lang;
    }
    push @tess-command, $tiff.absolute, 'stdout';
    my $proc = run-command(@tess-command, :out , :err);
    return $proc.out.slurp;
}

my sub generate-large-tiff(IO::Path::e $pdf --> IO::Path) {
    my $tiff = make-temp-path :suffix<.tiff>;
    my @tiff-command = ($convert, '-density', '300', $pdf.absolute, '-depth', '8', '-strip', '-background', 'white', '-alpha', 'off', $tiff.absolute);
    run-command(@tiff-command, :out, :err);
    die "coudn't generate large tiff at $tiff" unless $tiff.e;
    return $tiff;
}
