#!/usr/bin/env perl6

use v6.c;
use YAMLish;
use Data::Dump;
use App::Papierlos::WebApp;
use App::Papierlos::Project;

unit module App::Papierlos;

sub get-unprocessed(--> List) is export {
    return load-config<unprocessed>.IO.dir>>.Str;
}

sub get-store(--> List) is export {
    return load-config<store>.IO.dir>>.Str;
}

sub run-webapp() is export {
   my %projects = load-projects(load-config);
   App::Papierlos::WebApp::run(%projects);
}
