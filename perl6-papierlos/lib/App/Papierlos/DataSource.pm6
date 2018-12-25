use v6.c;

# read only data source

unit role App::Papierlos::DataSource;

has IO::Path $.base-path is required;

method list-contents(--> Seq) {
    return $.base-path.dir;
}