use v6.c;
use App::Papierlos::DataStore;
use StrictClass;
use Digest::MD5;
use MagickWand;

unit class App::Papierlos::Unprocessed does App::Papierlos::DataStore does StrictClass;

has %!md5-to-file;
has %!file-to-md5;
has $!md5 = Digest::MD5.new();

sub to-preview(Str:D $name --> Str) { $name ~ '.jpg' }

method get-all( --> Hash) {
    self!update-caches;

    my %all;
    for %!md5-to-file.keys -> $id {
        %all{$id} = self.get-details($id);
    }
    return %all;
}

method !update-caches() {
    my %new-md5-to-file;
    my %new-file-to-md5;
    for self.list-contents() {
        my $name = .absolute;
        my $md5sum = %!file-to-md5{$name};
        unless $md5sum {
            $md5sum = $!md5.md5_hex($name);
            %new-file-to-md5{$name} = $md5sum;
        }
        %new-md5-to-file{$md5sum} = $name;
    }
    %!md5-to-file = %new-md5-to-file;
    %!file-to-md5 = %new-file-to-md5;
}

method get-details(Str $id --> Hash) {
    my $name = %!md5-to-file{$id};
    die "could not find $id" unless $name.defined;
    my $file = $name.IO; 
    return {
        name => $file.basename,
        size => $file.s,
        id   => $id,
    };
}

method get-preview(Str $id --> Blob) {
    my $name = %!md5-to-file{$id};
    die "could not find $id" unless $name.defined;
    my $file = $name.IO;
    my $jpg = to-preview($name).IO;
    unless $jpg.e {
        my $w = MagickWand.new;
        LEAVE {
            $w.cleanup if $w.defined;
        }
        unless
            $w.read($name) and
            $w.adaptive-resize(0.25) and
            $w.write($jpg.absolute) {
            die "could not create preview for $name";
        }
    }
    die 'preview file was not generated' unless $jpg.e;
    return $jpg.slurp(:bin)
}