use v6.c;
use App::Papierlos::Project;
use App::Papierlos::Types;

use StrictClass;
use Digest::MD5;
use MagickWand;
use JSON::Fast;

unit class App::Papierlos::Project::Flat does StrictClass does App::Papierlos::Project;

# which contains path
sub convert-to-node(@path is copy, IO $path) {
    given $path {
        my $name = .basename;
        $name ~~ s/ '.pdf' $ // if $path.f;
        @path.push($name);
        when .d { return node 'dir',     :$name, :@path }
        when .f { return node 'file',    :$name, :@path, :size($path.s) }
        default { return node 'unknown', :$name, :@path }
    }
};

sub path-to-pdf(@path is copy --> Array) {
    @path[*-1] ~= '.pdf';
    return @path;
}

multi method get-children( --> Seq) {
    self.get-children(Array.new);
}
multi method get-children(@path --> Seq) {
    return $.datastore.list-contents(@path).map: &convert-to-node.assuming(@path)
}

method add-pdf(EntryName $name, $content, :%fields, Str :$extracted-text, Blob :$preview --> Array) {
    # there are no %fields or $extracted-text jet
    # implement only when neccesary
    my @path = [$name];
    my @pdf-path = path-to-pdf(@path);
    $.datastore.add-content(@pdf-path, $content);
    return @path;
}

method get-node-details(@path --> Hash) {
    my @pdf-path = path-to-pdf(@path);
    my $file = $.datastore.get-content: @pdf-path, :f;
    return convert-to-node(@path[0..^*], $file);
}

method get-preview(@path --> IO::Path) {
    my $file = self.get-pdf(@path);
    my $jpg = $file.parent.add($file.basename ~ '.jpg');
    unless $jpg.e {
        my $w = MagickWand.new;
        LEAVE {
            $w.cleanup if $w.defined;
        }
        unless
            $w.read($file.absolute) and
            $w.adaptive-resize(0.25) and
            $w.write($jpg.absolute)
        {
            my $name = @path.join: '/';
            die "could not create preview for $name";
        }
    }
    die 'preview file was not generated' unless $jpg.e;
    return $jpg;
}

method get-pdf(@path --> IO::Path){ 
    my @pdf-path = path-to-pdf(@path);
    my $file = $.datastore.get-content: @pdf-path, :f;
    return $file;
}
method get-fields(@path --> Hash) {
    my $file = self.get-pdf(@path);
    my $fields = $file.parent.add($file.basename ~ '_fields.json');
    my %fields = $fields.e ?? from-json($fields.slurp) !! ();
    return %fields;
}
