use v6.c;

use App::Papierlos::Project;
use App::Papierlos::Project::Common;
use App::Papierlos::Types;
use Subsets::IO;

use YAMLish;
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

sub path-to-fields(@path is copy --> Array) {
    my $filename = @path[*-1] ~ '.yml';
    push @path, $filename;
    return @path;
}

sub path-to-plaintext(@path is copy --> Array) {
    my $filename = @path[*-1] ~ '.txt';
    push @path, $filename;
    return @path;
}

multi method get-children( --> Seq) {
    self.get-children(Array[Str].new);
}
multi method get-children(@path --> Seq) {
    return $.datastore.list-contents(@path).map(&convert-to-node.assuming(@path)).grep(so *);
}

multi method add-pdf(EntryName $name, $content, :%fields, IO::Path::e :$plaintext, :@preview --> Array) {
    self.add-pdf($name, $content, :%fields, plaintext => $plaintext.slurp, :@preview);
}
multi method add-pdf(EntryName $name, $content, :%fields, Str :$plaintext, :@preview --> Array) {
    # ensure needed %fields where provided.
    my @path;
    for @.subdir-structure -> $name {
        die "field '$name' is missing, can not add $name" unless %fields{$name}:exists;
        push @path, %fields{$name};
    }

    push @path, $name;

    # Store PDF
    my @pdf-path = path-to-pdf(@path);
    my $pdf-file = $.datastore.add-content(@pdf-path, $content);

    # Store FIELDS
    my $fields = save-yaml(%fields);
    my @fields-path = path-to-fields(@path);
    $.datastore.add-content(@fields-path, $fields);

    # Store EXTRACTED PLAIN TEXT
    my @plain-path = path-to-plaintext(@path);
    $.datastore.add-content(@plain-path, $plaintext // generate-plaintext($pdf-file));

    return @path;
}

method get-node-details(@path --> Hash) {
    my @pdf-path = path-to-pdf(@path);
    my $pdf-dir = $.datastore.get-content(@path);
    my %details = convert-to-node(@path, $pdf-dir);
    return %details;
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
    my $file = $.datastore.get-content: @fields-path, :f;
    return load-yaml($file.slurp);
}
method get-plaintext(@path --> IO::Path) {
    my @plain-path = path-to-plaintext(@path);
    return $.datastore.get-content(@plain-path, :f);
}

method move(@path, App::Papierlos::Project :$to! --> Array) {
    my $name = @path[*-1];
    my $pdf = self.get-pdf(@path);
    my %fields = self.get-fields(@path);
    my $plaintext = self.get-plaintext(@path);
    my @preview = self.get-preview(@path);
    return $to.add-pdf($name, $pdf, :%fields, :$plaintext, :@preview);
}


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

