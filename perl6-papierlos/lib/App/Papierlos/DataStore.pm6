use v6.c;

# read/write data source
use App::Papierlos::DataSource;

unit role App::Papierlos::DataStore does App::Papierlos::DataSource;

my subset StrOrBlob of Cool where Str|Blob;

multi method add-content(Str $name, StrOrBlob $content) {
    $.base-path.add($name).spurt($content, :createonly);
}
multi method add-content(Str $name, IO $content) {
    my $dst = $.base-path.add($name);
    $content.copy($dst, :createonly);
}
