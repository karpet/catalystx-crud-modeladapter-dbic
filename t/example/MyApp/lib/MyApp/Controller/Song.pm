package MyApp::Controller::Song;
use strict;
use warnings;
use base qw( CatalystX::CRUD::Controller::RHTMLO );
use MyCRUD::Song::Form;

__PACKAGE__->config(
    form_class       => 'MyCRUD::Song::Form',
    init_form        => 'init_with_song',
    init_object      => 'song_from_form',
    default_template => 'song/edit.tt',           # you must create this!
    model_name       => 'Main',
    model_adapter    => 'MyCRUD::ModelAdapter',
    model_meta       => {
        dbic_schema    => 'Song',
        resultset_opts => {}
    },
    primary_key           => 'id',
    view_on_single_result => 1,
);

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->redirect( $c->uri_for('list') );
}

1;
