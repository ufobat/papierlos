use v6.c;

use App::Papierlos::DataStore;

unit role App::Papierlos::Project;

has $.datastore is required;

# @path is a directory, die if not.
multi method get-structure( --> Seq ) { ... }
multi method get-structure(@path --> Seq) { ... }

method add-pdf(Blob $content, :%fields, Str :$extraced-text, Blob :$preview --> Array) { ... }

# @path is a "file", die if not.
method get-details(@path) { ... }
method get-preview(@path --> Blob) { ... }
method get-pdf(@path --> Blob){ ... }
method get-fields(@path --> Hash) { ... }
