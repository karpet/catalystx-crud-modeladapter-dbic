use strict;
use warnings;
use ExtUtils::MakeMaker;
use lib qw( ../../CatalystX-CRUD/trunk/lib t );

WriteMakefile(
    NAME          => 'CatalystX::CRUD::ModelAdapter::DBIC',
    AUTHOR        => 'Peter Karman <karman@cpan.org>',
    VERSION_FROM  => 'lib/CatalystX/CRUD/ModelAdapter/DBIC.pm',
    ABSTRACT_FROM => 'lib/CatalystX/CRUD/ModelAdapter/DBIC.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More'                    => 0,
        'CatalystX::CRUD'               => 0.28,
        'DBIx::Class'                   => 0,
        'Catalyst::Model::DBIC::Schema' => 0,
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'CatalystX-CRUD-ModelAdapter-DBIC-*' },
);
