unit module App::Papierlos::Yaml;

use YAMLish;

sub tags-to-yaml(%tags --> Str) is export {
    my Str $output = "tags:\n";
    for %tags.kv -> $key, $value {
        if $value ~~ Str {
            $output ~= "  $key: $value\n";
        } elsif $value ~~ Positional {
            $output ~= "  $key:\n";
            for $value.values -> $item {
                $output ~= "    - $item\n";
            }
        }
    }

    # just that failed yamls dont get store
    load-yaml($output);

    return $output;
}
