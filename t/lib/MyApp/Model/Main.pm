package MyApp::Model::Main;
use base qw( Catalyst::Model::DBIC::Schema );

__PACKAGE__->config(
    schema_class => 'MyDB::Main',
    connect_info =>
        [ 'dbi:SQLite:' . MyApp->path_to() . '/../../example.db' ],

);

1;
