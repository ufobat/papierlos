use v6.c;
use App::Papierlos::Project;
use StrictClass;
use Digest::MD5;
use MagickWand;

unit class App::Papierlos::Project::Flat does StrictClass does App::Papierlos::Project;

sub convert-to-node(@path is copy, IO $path) {
    given $path {
        my $name = $path.basename;
        @path.push($name);
        when .d { return node 'dir',     :$name, :@path }
        when .f { return node 'file',    :$name, :@path, :size($path.s) }
        default { return node 'unknown', :$name, :@path }
    }
};

multi method get-children( --> Seq) {
    self.get-children(Array.new);
}
multi method get-children(@path --> Seq) {
    return $.datastore.list-contents(@path).map: &convert-to-node.assuming(@path)
}

method add-pdf(Blob $content, :%fields, Str :$extracted-text, Blob :$preview --> Array) {
    # there are no %fields or $extracted-text jet
    # implement only when neccesary
    # die 'can only store pdfs' unless @path[*-1] ~~ m:i/ '.pdf' $ /;
    ...
    # my @path;
    # $.datastore.add-content(@path, $content);
}

method get-node-details(@path --> Hash) {
    my $file = $.datastore.get-content(@path);
    return convert-to-node(@path[0..^*], $file);
}

method get-preview(@path --> Blob) {
    my $file = $.datastore.get-content(@path);
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
    return $jpg.slurp(:bin)
}

method get-pdf(@path --> Blob){ ... }
method get-fields(@path --> Hash) { ... }
