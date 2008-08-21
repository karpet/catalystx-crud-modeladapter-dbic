package MyDB::Main::Cd;
use base qw/DBIx::Class/;
__PACKAGE__->load_components(qw/IntrospectableM2M Core/);
__PACKAGE__->table('cd');
__PACKAGE__->add_columns(qw/ cdid artist title/);
__PACKAGE__->set_primary_key('cdid');
__PACKAGE__->belongs_to( 'artist' => 'MyDB::Main::Artist' );
__PACKAGE__->has_many( 'tracks' => 'MyDB::Main::Track' );
__PACKAGE__->has_many(
    'cd_tracks' => 'MyDB::Main::CdTrackJoin',
    'cdid'
);
__PACKAGE__->many_to_many(
    'multitracks' => 'cd_tracks',
    'trackid'
);

1;
