package MyDB::Main::Track;
use base qw/DBIx::Class/;
__PACKAGE__->load_components(qw/IntrospectableM2M Core/);
__PACKAGE__->table('track');
__PACKAGE__->add_columns(qw/ trackid cd title/);
__PACKAGE__->set_primary_key('trackid');
__PACKAGE__->belongs_to( 'cd' => 'MyDB::Main::Cd' );
__PACKAGE__->has_many(
    'cd_tracks' => 'MyDB::Main::CdTrackJoin',
    'trackid'
);
__PACKAGE__->many_to_many(
    'cds' => 'cd_tracks',
    'cdid'
);

1;
