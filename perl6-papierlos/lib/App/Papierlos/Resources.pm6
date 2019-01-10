use v6.c;

# interface to the %?RESOURCES for the tests

unit module App::Papierlos::Resources;

sub get-resource(Str $id) is export {
    return %?RESOURCES{$id}.IO;
}