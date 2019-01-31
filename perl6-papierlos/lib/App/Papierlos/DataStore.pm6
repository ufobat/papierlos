use v6.c;

# read only data source
use IO::Path::ChildSecure;
use StrictClass;

unit class App::Papierlos::DataStore does StrictClass;

has IO::Path $.base-path is required;

method add-content(@name, $content --> IO::Path) {
    die "no file name specified {{ @name }}" if @name.elems < 0;
    my $file = $.base-path;
    my $dir;
    for @name {
        $dir = $file;
        $dir.mkdir unless $dir.e;
        $file = $file.&child-secure: $_;
    }

    given $content {
        when IO {
            $content.copy($file, :createonly);
        }
        default {
            $file.spurt($content, :createonly);
        }
    }
    return $file;
}

multi method list-contents(:$test--> Seq) {
    return self.list-contents(Array[Str].new, |(:$test with $test));
}
multi method list-contents(@path, :$test --> Seq) {
    my $dir = $.base-path;
    $dir = $dir.&child-secure: $_ for @path;
    return $dir.dir: |(:$test with $test);
}

method get-content(@path, Bool :$f = False --> IO::Path) {
    my $file = $.base-path;
    $file = $file.&child-secure: $_ for @path;
    if $f {
        die "did not find a file with get-content for '{ @path }" unless $file.f;
    }
    return $file;
}
