package MyApp::Controller::Album;
use strict;
use warnings;
use base qw( CatalystX::CRUD::Controller::RHTMLO );

__PACKAGE__->config(
    form_class       => 'MyCRUD::Album::Form',
    init_form        => 'init_with_album',
    init_object      => 'album_from_form',
    default_template => 'album/edit.tt',          # you must create this!
    model_name       => 'Main',
    model_adapter    => 'MyCRUD::ModelAdapter',
    model_meta       => {
        dbic_schema    => 'Album',
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
