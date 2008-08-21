package MyDB::Main::CdTrackJoin;
use base qw/DBIx::Class/;
__PACKAGE__->load_components(qw/ IntrospectableM2M Core /);
__PACKAGE__->table('cd_track_join');
__PACKAGE__->add_columns(qw/ trackid cdid id /);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to( 'cdid'    => 'MyDB::Main::Cd' );
__PACKAGE__->belongs_to( 'trackid' => 'MyDB::Main::Track' );

1;
