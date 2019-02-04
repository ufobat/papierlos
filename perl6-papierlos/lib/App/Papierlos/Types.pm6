use v6.c;
use Subset::Helper;

my subset EntryName is export
    of Str:D
    where subset-is { $_ ~~ m/ <[a..zA..Z0..9]>+ % \s /},
    'Value must be an ascii name with spaces';
