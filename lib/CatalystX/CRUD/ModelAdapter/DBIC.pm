package CatalystX::CRUD::ModelAdapter::DBIC;
use warnings;
use strict;
use base qw( CatalystX::CRUD::ModelAdapter CatalystX::CRUD::Model::Utils );
use Class::C3;
use Scalar::Util qw( weaken );

our $VERSION = '0.01';

=head1 NAME

CatalystX::CRUD::ModelAdapter::DBIC - CRUD for Catalyst::Model::DBIC::Schema

=head1 SYNOPSIS

 # create an adapter class (NOTE not in ::Model namespace)
 package MyApp::MyDBICAdapter;
 use strict;
 use base qw( CatalystX::CRUD::ModelAdapter::DBIC );
 
 1;
 
 # your main DBIC::Schema model
 package MyApp::Model::MyDBIC;
 use strict;
 use base qw( Catalyst::Model::DBIC::Schema );
 
 1;
 
=head1 DESCRIPTION


=head1 METHODS


=cut

sub new_object {
    my $self       = shift;
    my $controller = shift;
    my $c          = shift;
    my $moniker    = $self->_get_moniker( $controller, $c );
    return $c->model( $self->model_name )->resultset($moniker)
        ->new_result( {} );
}

sub fetch {
    my $self       = shift;
    my $controller = shift;
    my $c          = shift;
    my $moniker    = $self->_get_moniker( $controller, $c );
    if (@_) {
        my $dbic_obj;
        eval {
            $dbic_obj
                = $c->model( $self->model_name )->resultset($moniker)
                ->find( {@_} );
        };
        if ( $@ or !$dbic_obj ) {
            my $err = defined($dbic_obj) ? $dbic_obj->error : $@;
            return
                if $self->throw_error(
                "can't create new $moniker object: $err");
        }

        return $dbic_obj;
    }
    else {
        return $self->new_object( $controller, $c );
    }
}

sub search {
    my ( $self, $controller, $c, @arg ) = @_;
    my $query = shift(@arg) || $self->make_query( $c, $controller );
    my @rs
        = $c->model( $self->model_name )
        ->resultset( $self->_get_moniker( $controller, $c ) )
        ->search(@$query);
    return wantarray ? @rs : \@rs;
}

sub _get_moniker {
    my ( $self, $controller, $c ) = @_;
    my $moniker = $c->stash->{dbic_schema}
        || $controller->model_meta->{dbic_schema}
        or $self->throw_error(
        "must define a dbic_schema for each CRUD controller");
    return $moniker;
}

sub iterator {
    my ( $self, $controller, $c, @arg ) = @_;
    my $query = shift(@arg) || $self->make_query( $c, $controller );
    my $rs
        = $c->model( $self->model_name )
        ->resultset( $self->_get_moniker( $controller, $c ) )
        ->search(@$query);
    return $rs;
}

sub count {
    my ( $self, $controller, $c, @arg ) = @_;
    my $query = shift(@arg) || $self->make_query( $c, $controller );
    return $c->model( $self->model_name )
        ->resultset( $self->_get_moniker( $controller, $c ) )->count(@$query);
}

sub make_query {
    my $self        = shift;
    my $c           = shift;
    my $controller  = shift;
    my $field_names = shift
        || $self->_get_field_names( $controller, $c );

    # TODO sort order and limit/offset support
    # it's already in $q but need DBIC syntax

    # Model::Utils (make_sql_query) assumes ACCEPT_CONTEXT accessor
    $self->{context} = $c;
    weaken( $self->{context} );

    my @query;
    my $q = $self->make_sql_query($field_names);

    push( @query,
        { @{ $q->{query} } },
        $controller->model_meta->{resultset_opts} )
        if $controller->model_meta->{resultset_opts};

    return \@query;
}

sub _get_field_names {
    my $self       = shift;
    my $controller = shift;
    my $c          = shift;
    return $self->{_field_names} if $self->{_field_names};

    my $obj = $c->model( $self->model_name )
        ->composed_schema->source( $self->_get_moniker( $controller, $c ) );
    my @cols = $obj->columns;
    my @rels = $obj->relationships;

    my @fields;
    for my $rel (@rels) {
        my $info      = $obj->relationship_info($rel);
        my $rel_class = $info->{source};
        my @rel_cols  = $rel_class->columns;
        push( @fields, map { $rel . '.' . $_ } @rel_cols );
    }
    for my $col (@cols) {
        push( @fields, 'me.' . $col );
    }

    $self->{_field_names} = \@fields;

    return \@fields;
}

sub create {
    my ( $self, $c, $object ) = @_;
    $object->insert;
}

sub read {
    my ( $self, $c, $object ) = @_;
    $object->find;    # TODO is this right?
}

sub update {
    my ( $self, $c, $object ) = @_;
    $object->update;

}

sub delete {
    my ( $self, $c, $object ) = @_;
    $object->delete;
}

=head1 AUTHOR

Peter Karman, C<< <karman at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-catalystx-crud-modeladapter-dbic at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CatalystX-CRUD-ModelAdapter-DBIC>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CatalystX::CRUD::ModelAdapter::DBIC

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CatalystX-CRUD-ModelAdapter-DBIC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CatalystX-CRUD-ModelAdapter-DBIC>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CatalystX-CRUD-ModelAdapter-DBIC>

=item * Search CPAN

L<http://search.cpan.org/dist/CatalystX-CRUD-ModelAdapter-DBIC>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Peter Karman, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
