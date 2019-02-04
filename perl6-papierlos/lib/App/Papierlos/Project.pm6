use v6.c;

use App::Papierlos::DataStore;
use App::Papierlos::Types;

unit role App::Papierlos::Project;

has $.datastore is required;

# @path is a non-leaf, die if not.
multi method get-children( --> Seq ) { ... } # same as @path = ();
multi method get-children(@path --> Seq) { ... }

# @path is a "leaf", die if not.
method get-preview(@path --> Seq) { ... }
method get-pdf(@path --> IO::Path) { ... }
method get-fields(@path --> Hash) { ... }
method get-plaintext(@path --> IO::Path) { ... }

# projects decide depending on the %fields where to put the PDF document
method add-pdf(EntryName $name, $content, :%fields, Str :$extraced-text, Blob :$preview --> Array) { ... }

# works for all @paths
# die on @path = () because we don't need that.
method get-node-details(@path) { ... }

# factory sub for different nodes in the tree
multi sub node('file', Str :$name!, :@path!, Int :$size --> Hash) is export {
    return {
        :type<file>,
        :$name,
        :@path,
        :$size,
    };
}
multi sub node('dir', Str :$name!, :@path! --> Hash) is export {
    return {
        :type<dir>,
        :$name,
        :@path,
    };
}
multi sub node('unknown', Str :$name!, :@path! --> Hash) is export {
    return {
        :type<unknown>,
        :$name,
        :@path,
    };
}
