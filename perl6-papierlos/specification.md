# REST Data Structure
## dir
{
    'type': 'dir',
    'name': 'subdir',
    'path': ['dir', 'subdir'],
}
## file
{
    'type': 'file',
    'name': 'filename.pdf',
    'path': ['path', 'to', 'filename.pdf'],
}

# REST API
## unprocessed
* GET  /unprocessed/structure/<*@path>
* POST /unprocessed/pdf/
    - with fileupload
* GET  /unprocessed/pdf/<$id>
* GET  /unprocessed/details/<$id>
* GET  /unprocessed/preview/<$id>
* POST /unprocessed/store/<$id> 
    # returns Location header!?
    - with: {
        'tags': { # can be used to retag
            'key': 'value-pairs',
        },
        'project': '<$name>', # can be used to change the project
    }
## projects
* GET /projects
* GET /projects/<$name>/structure/<*@path>
* GET /projects/<$name>/pdf/<$id>
* GET /projects/<$name>/details/<$id>
* GET /projects/<$name>/preview/<$id>
* POST /projects/<$name>/search
    - with {
        'query': 'query-string'
    }

# Backend API
## DataSource
```
method list-contents(Str @path --> Seq) { ... }
```

## DataStore does DataSource
```
multi method add-content(Str @path, StrOrBlob $content) { ... }
multi method add-content(Str @path, IO $content) { ... } 
method del-content(Str @path) { ... }
```

# Unprocessed
```
method get-all(Str @path--> List) { ... }
method get-details(Str $id --> Hash) { ... }
method get-preview(Str $id --> Blob) { ... }
method add-pdf(Str $name, Blob $content) { ... }
```

# Project
```
method get-all(Str @path --> Hash) { ... }
method get-details(Str $id --> Hash) { ... }
method get-preview(Str $id --> Blob) { ... }

```
