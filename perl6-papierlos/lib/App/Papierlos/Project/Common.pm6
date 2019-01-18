use v6.c;
use MagickWand;

unit module App::Papierlos::Project::Common;

sub generate-preview(Str $name, IO::Path $pdf, IO::Path $jpg) is export {
        my $w = MagickWand.new;
        LEAVE {
            $w.cleanup if $w.defined;
        }
        unless
            $w.read($pdf.absolute) and
            $w.adaptive-resize(0.25) and
            $w.write($jpg.absolute)
        {
            die "could not create preview for $name";
        }   
}
