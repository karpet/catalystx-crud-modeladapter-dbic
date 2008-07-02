package MyApp;
use strict;
use warnings;
use Catalyst;
use Catalyst::Runtime;

__PACKAGE__->setup();

# mimic testdb.pl from the cookbook
sub test1 : Local {
    my ( $self, $c ) = @_;

    my $schema = $c->model('Main')->schema;
    my $count  = 0;

    get_tracks_by_cd( $schema, \$count, 'Bad' );
    get_tracks_by_artist( $schema, \$count, 'Michael Jackson' );

    get_cd_by_track( $schema, \$count, 'Stan' );
    get_cds_by_artist( $schema, \$count, 'Michael Jackson' );

    get_artist_by_track( $schema, \$count, 'Dirty Diana' );
    get_artist_by_cd( $schema, \$count, 'The Marshall Mathers LP' );

    $c->res->body($count);
}

#################################################################
## private functions

sub get_tracks_by_cd {
    my $schema  = shift;
    my $count   = shift;
    my $cdtitle = shift;
    my $rs      = $schema->resultset('Track')->search(
        { 'cd.title' => $cdtitle },
        {   join     => [qw/ cd /],
            prefetch => [qw/ cd /]
        }
    );
    while ( my $track = $rs->next ) {
        $$count++;
    }

}

sub get_tracks_by_artist {
    my $schema     = shift;
    my $count      = shift;
    my $artistname = shift;
    my $rs         = $schema->resultset('Track')->search(
        { 'artist.name' => $artistname },
        { join          => { 'cd' => 'artist' }, }
    );
    while ( my $track = $rs->next ) {
        $$count++;
    }

}

sub get_cd_by_track {
    my $schema     = shift;
    my $count      = shift;
    my $tracktitle = shift;

    my $rs
        = $schema->resultset('Cd')->search( { 'tracks.title' => $tracktitle },
        { join => [qw/ tracks /], } );
    my $cd = $rs->first;
    $$count++;
}

sub get_cds_by_artist {
    my $schema     = shift;
    my $count      = shift;
    my $artistname = shift;

    my $rs = $schema->resultset('Cd')->search(
        { 'artist.name' => $artistname },
        {   join     => [qw/ artist /],
            prefetch => [qw/ artist /]
        }
    );
    while ( my $cd = $rs->next ) {
        $$count++;
    }

}

sub get_artist_by_track {
    my $schema     = shift;
    my $count      = shift;
    my $tracktitle = shift;

    my $rs = $schema->resultset('Artist')->search(
        { 'tracks.title' => $tracktitle },
        { join           => { 'cds' => 'tracks' } }
    );
    my $artist = $rs->first;
    $$count++;
}

sub get_artist_by_cd {
    my $schema  = shift;
    my $count   = shift;
    my $cdtitle = shift;

    my $rs = $schema->resultset('Artist')
        ->search( { 'cds.title' => $cdtitle }, { join => [qw/ cds /], } );
    my $artist = $rs->first;
    $$count++;
}

1;

