use v6.c;
use App::Papierlos::Project;
use App::Papierlos::Types;
use App::Papierlos::Project::Common;

use StrictClass;
use YAMLish;

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
sub path-to-plaintext(@path is copy --> Array) {
    @path[*-1] ~= '.txt';
    return @path;
}
sub path-to-fields(@path is copy --> Array) {
    @path[*-1] ~= '.yml';
    return @path;
}

multi method get-children( --> Seq) {
    self.get-children(Array.new);
}
multi method get-children(@path --> Seq) {
    return $.datastore.list-contents(@path).map: &convert-to-node.assuming(@path)
}
multi method add-pdf(EntryName $name, $content, :%fields, IO::Path :$plaintext, :@preview --> Array) {
    self.add-pdf($name, $content, :%fields, plaintext => $plaintext.slurp, :@preview);
}
multi method add-pdf(EntryName $name, $content, :%fields, Str :$plaintext, :@preview --> Array) {
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

method get-preview(@path --> Seq) {
    my $file = self.get-pdf(@path);
    my @jpgs = list-preview($file.parent, $file.basename);
    @jpgs = generate-preview($file) unless @jpgs;
    die 'preview file was not generated' unless @jpgs;
    return @jpgs.Seq;
}

method get-pdf(@path --> IO::Path){
    my @pdf-path = path-to-pdf(@path);
    my $file = $.datastore.get-content: @pdf-path, :f;
    return $file;
}

method get-fields(@path --> Hash) {
    my @fields-path = path-to-fields(@path);
    my $file = $.datastore.get-content: @fields-path;
    my %fields = $file.e ?? load-yaml($file.slurp) !! ();
    return %fields;
}

method get-plaintext(@path --> IO::Path) {
    my @plain-path = path-to-plaintext(@path);
    my $plaintext-file = $.datastore.get-content(@plain-path);
    unless $plaintext-file.e {
        my $pdf-file = self.get-pdf(@path);
        my $plain-text = generate-plaintext($pdf-file);
        $.datastore.add-content(@plain-path, $plain-text);
    }
    return $plaintext-file;
}
