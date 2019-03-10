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
* GET  /api/unprocessed/  # get all
* GET  /api/unprocessed/structure/<*@path>
* POST /api/unprocessed/pdf/
    - with fileupload
* GET  /api/unprocessed/pdf/<$id>
* GET  /api/unprocessed/details/<$id>
* GET  /api/unprocessed/preview/<$id>
* POST /api/unprocessed/store/<$id>
    # returns Location header!?
    - with: {
        'fields: { # can be used to retag
            'key': 'value-pairs',
        },
        'project': '<$name>', # can be used to change the project
    }
## projects
* GET  /api/projects
* GET  /api/projects/<$name>/structure/<*@path>
* GET  /api/projects/<$name>/pdf/<$id>
* GET  /api/projects/<$name>/details/<$id>
* GET  /api/projects/<$name>/preview/<$id>
* POST /api/projects/<$name>/search
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
