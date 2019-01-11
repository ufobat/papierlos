use v6.c;

use IoC;
use YAMLish;
use App::Papierlos::Project::Flat;
use App::Papierlos::Project::Structured;
use App::Papierlos::Projects;
use App::Papierlos::Cro::Routes;
use App::Papierlos::Cro::Runner;

unit module App::Papierlos::IoC;

our $Container is export = container 'papierlos' => contains {
    service 'configfile' => {
        :lifecycle('Singleton'),
        block => sub (--> IO) {
            my $configfile;
            with %*ENV<PAPIERLOS_CONFIG> {
                $configfile = .IO;
            }
            orwith $*CWD {
                $configfile = .child('papierlos.yml');
            }
            orwith %*ENV<HOME> {
                $configfile = .IO.child('.papierlos.yml');
            }
            orwith %*ENV<HOME> {
                $configfile = .IO.child('.config/papierlos.yml');
            }
            die "dont know the path to configfile" unless $configfile.defined;
            die "could not load configfile $configfile" unless $configfile.e;
            return $configfile;
        }
    };

    service 'configuration' => {
        :lifecycle('Singleton'),
        dependencies => {
            'configfile' => 'configfile',
        },
        block => sub ($service, --> Hash) {
            my $configfile = $service.param('configfile');
            my %config = load-yaml($configfile.slurp);
            # validate %config with JSON::Schema
            # my $schema = JSON::Schema.new( schema => );
            # $schema.validate(%config);
            return %config;
        }
    };

    service 'unprocessed-store' => {
        :lifecycle('Singleton'),
        dependencies => {
            'configuration' => 'configuration',
        },
        block => sub ($service, --> App::Papierlos::DataStore) {
            my %config = $service.param('configuration');
            return App::Papierlos::DataStore.new(
                :base-path(%config<store><unprocessed>.IO)
            );
        }
    };
    service 'unprocessed' => {
        :lifecycle<Singelton>,
        :type(App::Papierlos::Project::Flat),
        dependencies => {
            'datastore' => 'unprocessed-store'
        },
    };

    # service 'project-base-dirs' => {
    #     :lifecycle('Singelton'),
    #     dependencies => {
    #         'configuration' => 'configuration',
    #     },
    #     block => sub ($service, --> Seq) {
    #         my %config = $service.param('configuration');
    #         return gather for %config<projects>.kv -> $name, $project-settings {
    #             take $name => App::Papierlos::Project::BaseDir.new(
    #                 base-path => %config<store><projects>.IO.add($name),
    #                 subdir-structure => $project-settings<subdir-structure>.flat,
    #             );
    #         }
    #     }
    # };

    service 'projects' => {
        :lifecycle('Singleton'),
        dependencies => {
            'configuration' => 'configuration',
            'unprocessed' => 'unprocessed',
        },
        block => sub ($service, --> App::Papierlos::Projects) {
            my %config = $service.param('configuration');
            my $unprocessed = $service.param('unprocessed');

            my %projects = gather for %config<projects>.kv -> $name, $project-settings {
                my $datastore = App::Papierlos::DataStore.new( :base-path(%config<store><projects>.IO.add($name)) );
                take $name => App::Papierlos::Project::Structured.new(
                    :$name,
                    :$datastore,
                    subdir-structure => $project-settings<subdir-structure>.flat,
                );
            }
            return App::Papierlos::Projects.new( :%projects, :$unprocessed );
        }
    };

    service 'cro-routes' => {
        type => App::Papierlos::Cro::Routes,
        dependencies => {
            :unprocessed('unprocessed-store')
        },
    };

    service 'cro-app-runner' => {
        type => App::Papierlos::Cro::Runner,
        dependencies => {
            :routes('cro-routes'),
            # :host( literal('localhost') ),
            # :port( literal(80) ),
        }
    };

    # service 'cro-rest-app' => {
    #     dependencies => {
    #         'projects' => 'projects',
    #     },
    #     block => sub ($service, --> App::Papierlos::WebApp) {
    #         my %projects = $service.param('projects');
    #         App::Papierlos::WebApp::run(%projects);
    #     }
    # }; 
};
