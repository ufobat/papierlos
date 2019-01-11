use v6.c;
use App::Papierlos::Project;
use StrictClass;
use Digest::MD5;
use MagickWand;

unit class App::Papierlos::Project::Flat does StrictClass does App::Papierlos::Project;

sub to-preview($file) {
    my $name = $file.basename ~ '.jpg';
    my $parent = $file.parent;
    return $parent.add($name);
}
sub to-web-response(@path, IO $path) {
    my $name = $path.basename;
    my $type = 'dir' if $path.d;
    my $size = 0;
    if $path.f {
        $type = 'file',
        $size = $path.s;
    };
    return unless $type;
    return {
        :$type,
        :$name,
        :$size,
        :path(|@path, $name),
    };
}

multi method get-all( --> Seq) {
    self.get-all(Array[Str].new);
}
multi method get-all(@path --> Seq) {
    my &convert = &to-web-response.assuming(@path);
    return $.datastore.list-contents(@path).map(&convert).grep(*.so);
}

method get-details(@path --> Hash) {
    my $file = $.datastore.get-content(@path);
    return {
        name => $file.basename,
        size => $file.s,
        :path(@path.List),
        :type<file>,
    };
}

method get-preview(@path --> Blob) {
    my $file = $.datastore.get-content(@path);
    my $jpg = to-preview($file);
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

method add-new-pdf(@path, Blob $content) {
    die 'can only store pdfs' unless @path[*-1] ~~ m:i/ '.pdf' $ /;
    $.datastore.add-content(@path, $content);
}
