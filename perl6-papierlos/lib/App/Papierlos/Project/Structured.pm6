use v6.c;

use App::Papierlos::Project;
use App::Papierlos::Yaml;
use App::Papierlos::Project::Common;

use StrictClass;

unit class App::Papierlos::Project::Structured does StrictClass does App::Papierlos::Project;

has Str $.name is required;
has Str @.subdir-structure is required;

sub convert-to-node(@path is copy, IO $path) {
    my $name = $path.basename;

    if $path.d and (my $pdf-file = $path.add($name ~ '.pdf')).e {
        return node 'file', :$name, :@path, :size($pdf-file.s);
    } elsif $path.d {
        @path.push: $name;
        return node 'dir', :$name, :@path;
    } elsif $path.f {
        # skip them
        return;
    } else {
        @path.push: $name;
        return node 'unknown', :$name, :@path;
    }
};

sub path-to-pdf(@path is copy --> Array) {
    my $filename = @path[*-1] ~ '.pdf';
    push @path, $filename;
    return @path;
}

sub path-to-preview(@path is copy --> Array) {
    my $filename = @path[*-1] ~ '.jpg';
    push @path, $filename;
    return @path;
}

multi method get-children( --> Seq) {
    self.get-children(Array[Str].new);
}
multi method get-children(@path --> Seq) {
    return $.datastore.list-contents(@path).map(&convert-to-node.assuming(@path)).grep(so *);
}

method add-pdf(Str $name, $content, :%fields, Str :$extraced-text, Blob :$preview --> Array) { ... }

method get-node-details(@path --> Hash) {
    my @pdf-path = path-to-pdf(@path);
    my $pdf-dir = $.datastore.get-content(@path);
    my %details = convert-to-node(@path, $pdf-dir);
    return %details;
}
method get-preview(@path --> IO::Path) {
    my @preview-path = path-to-preview(@path);
    my $jpg = $.datastore.get-content: @preview-path;
    unless $jpg.e {
        my $pdf = self.get-pdf;
        my $name = @path.join: '/';
        generate-preview($name, $pdf, $jpg);
    }
    die 'preview file was not generated' unless $jpg.e;
    return $jpg;
}
method get-pdf(@path --> IO::Path){
    my @pdf-path = path-to-pdf(@path);
    my $file = $.datastore.get-content: @pdf-path, :f;
    return $file;
}
method get-fields(@path --> Hash) { ... }

# class App::Papierlos::Project::BaseDir does App::Papierlos::DataSource does StrictClass {
#     has Str @.subdir-structure is required;

#     method !do-tags-match-subdir-structure(%tags --> IO::Path) {
#         my $new-base-path = $.base-path;
#         for @!subdir-structure {
#             if %tags{$_}:exists {
#                 unless %tags{$_} ~~ Str {
#                     die "required tag '$_' must only be specified once: %tags{$_}";
#                 }
#                 $new-base-path = $new-base-path.add(%tags{$_});
#             } else {
#                 die "required tag '$_' is not provided";
#             }
#         }
#         return $new-base-path;
#     }


#     method get-content-container(Str %tags) {
#         my $new-base-path = self!do-tags-match-subdir-structure(%tags);
#         return App::Papierlos::Project::ContentContainer.new( :base-path($new-base-path) );
#     }
# }

# class App::Papierlos::Project {
#     has Str $.name is required;
#     has App::Papierlos::Unprocessed $.unprocessed is required;
#     has App::Papierlos::Project::BaseDir $.basedir is required;

#     method store-file(
#         IO::Path:D $sourcefile,
#         Str:D %tags,
#         Str:D :$new-name,
#     ) {
#         my $container = $.basedir.get-content-container(%tags);
#         my $tags-yaml = tags-to-yaml(%tags);
#         my $document-name = $new-name.defined
#             ?? $new-name
#             !! $sourcefile.basename;

#         try {
#             $container.create-base-path();
#             $container.add-content('tags.yaml', $tags-yaml);
#             $container.add-content('content.txt', '');
#             $container.add-content($document-name, $sourcefile);
#             $sourcefile.unlink;

#             CATCH {
#                 default {
#                     warn $_;
#                     # cleanup
#                     $container.remove-base-path();
#                     die "removing $container.base-path";
#                 }
#             }
#         }
#     }
# }

# class App::Papierlos::Project::ContentContainer does App::Papierlos::DataStore {
#     method create-base-path() {
#         $.base-path.mkdir();
#     }

#     method remove-base-path() {
#         $.base-path.rmdir();
#     }

#     method list-contents {
#         return $.base-path.dir;
#     }
# }

