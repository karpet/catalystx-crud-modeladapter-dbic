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

=head2 new_object( I<controller>, I<context>, I<moniker> )

Implement required method. Returns empty new_result() object
from resultset() of I<moniker>.

=cut

sub new_object {
    my $self       = shift;
    my $controller = shift;
    my $c          = shift;
    my $moniker    = $self->_get_moniker( $controller, $c );
    return $c->model( $self->model_name )->resultset($moniker)
        ->new_result( {} );
}

=head2 fetch( I<controller>, I<context>, I<moniker> [, I<args>] )

Implements required method. Returns new_object() matching I<args>.
I<args> is passed to the find() method of the resultset() for I<moniker>.
If I<args> is not passed, fetch() acts the same as calling new_object().

=cut

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

=head2 search( I<controller>, I<context>, I<args> )

Implements required method. Returns array or array ref, based
on calling context, for a search() in resultset() for I<args>.

=cut

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

=head2 iterator( I<controller>, I<context>, I<args> )

Implements required method. Returns iterator
for a search() in resultset() for I<args>.

=cut

sub iterator {
    my ( $self, $controller, $c, @arg ) = @_;
    my $query = shift(@arg) || $self->make_query( $c, $controller );
    my $rs
        = $c->model( $self->model_name )
        ->resultset( $self->_get_moniker( $controller, $c ) )
        ->search(@$query);
    return $rs;
}

=head2 count( I<controller>, I<context>, I<args> )

Implements required method. Returns count() in resultset() for I<args>.

=cut

sub count {
    my ( $self, $controller, $c, @arg ) = @_;
    my $query = shift(@arg) || $self->make_query( $c, $controller );
    return $c->model( $self->model_name )
        ->resultset( $self->_get_moniker( $controller, $c ) )->count(@$query);
}

=head2 make_query( I<context>, I<controller>, I<field_names> )

Returns an array ref of query data based on request params in I<context>,
using param names that match I<field_names>.

=cut

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

=head2 create( I<context>, I<dbic_object> )

Calls insert() on I<dbic_object>.

=cut

sub create {
    my ( $self, $c, $object ) = @_;
    $object->insert;
}

=head2 read( I<context>, I<dbic_object> )

Calls find() on I<dbic_object>.

=cut

sub read {
    my ( $self, $c, $object ) = @_;
    $object->find;    # TODO is this right?
}

=head2 update( I<context>, I<dbic_object> )

Calls update() on I<dbic_object>.

=cut

sub update {
    my ( $self, $c, $object ) = @_;
    $object->update;

}

=head2 delete( I<context>, I<dbic_object> )

Calls delete() on I<dbic_object>.

=cut

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
