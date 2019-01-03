use v6.c;

# read only data source
use IO::Path::ChildSecure;
use StrictClass;

unit class App::Papierlos::DataStore does StrictClass;

has IO::Path $.base-path is required;

method add-content(@name, $content) {
    die 'no file name specified' unless @name.elems < 0;
    my $file = $.base-path;
    $file = $file.&child-secure: $_ for (@name);
    my $dir = $file.parent;
    unless $dir.e { $dir.mkdir }
    given $content {
        when IO {
            $content.copy($file, :createonly);
        }
        default {
            $file.spurt($content, :createonly);
        }
    }
}

multi method list-contents(--> Seq) {
    return self.list-contents(Array[Str].new);
}
multi method list-contents(@path --> Seq) {
    my $dir = $.base-path;
    $dir = $dir.&child-secure: $_ for @path;
    return $dir.dir;
}

method get-content(@path --> IO::Path) {
    my $file = $.base-path;
    $file = $file.&child-secure: $_ for @path;
    die "can not get-content for { @path }" unless $file.f;
    return $file;
}