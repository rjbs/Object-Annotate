
package Object::Annotate;
use strict;
use warnings;

=head1 NAME

Object::Annotate - mix in logging-to-database to objects

=head1 VERSION

 $Id$

version 0.01

=cut

our $VERSION = '0.01';

use Carp;
use Sub::Install;
use UNIVERSAL::moniker;

=head1 SYNOPSIS

  package Your::Class;
  use Object::Annotate { dsn => '...', table => 'notes' };

  ...

  my $object = Your::Class->new( ... );
  $object->annotate({ event => "created", comment => "(as example)" });

=head1 DESCRIPTION

Valid arguments to pass to Object::Annotate's import routine are:

  obj_class - the class name to use for annotations for this class
              (defaults to Class->moniker, see UNIVERSAL::moniker)
  id_attr   - the object attribute to use for "id"; called as a method
              if it's a scalar ref, it's de-ref'd and used as a constant string

=cut

# We'll store the constructed Class::DBI subclasses here.
# $class_for->{ $dsn }->{ $table } = $class
my $class_for = {};

# We'll keep a counter, here, to use to form unique class names.
my $current_suffix = 0;

my %note_columns = (
  auto   => [ qw(class object_id note_time) ],
  manual => [ qw(event attr old_val new_val via comment expire_time) ],
);

sub import {
  my ($self, $arg) = @_;
  my $caller = caller(0);

  my $class = $self->class_for($arg);

  my $annotator = $self->build_annotator({
    class     => $class,
    obj_class => $arg->{obj_class} || $caller->moniker,
    id_attr   => $arg->{id_attr} || 'id',
  });

  Sub::Install::install_sub({
    code => $annotator,
    into => $caller,
    as   => 'annotate'
  });

  Sub::Install::install_sub({
    code => sub { $class },
    into => $caller,
    as   => 'annotation_class'
  });
}

=head1 METHODS

=head2 C< class_for >

  my $class = Object::Annotate->class_for(\%arg);

This method returns the class to use for the described database and table,
constructing it (see C<L</construct_class>>) if needed.

Valid arguments are:

  dsn   - the dsn for the database in which to store
  table - the table in which to store annotations

=cut

sub class_for {
  my ($self, $arg) = @_;

  my $dsn   = $arg->{dsn}   || 'dbi:Pg:dbname=icg;host=licorice.pobox.com;sslmode=prefer';
  my $table = $arg->{table} || 'annotations';

  # Try to find an already-constructed class.
  my $class = exists $class_for->{ $dsn }
           && exists $class_for->{ $dsn }->{ $table }
           && $class_for->{ $dsn }->{ $table };

  # If we have no class built for this combination, build it.
  $class ||= $self->construct_class({ dsn => $dsn, table => $table });

  return $class;
}

=head2 C< construct_class >

  my $new_class = Object::Annotate->construct_class(\%arg);

This method sets up a new Class::DBI subclass that will store in the database
described by the arguments.

Valid arguments are:

  dsn   - the dsn for the database in which to store
  table - the table in which to store annotations

=cut

sub construct_class {
  my ($class, $arg) = @_;

  my $new_class
    = sprintf 'Object::Annotate::Construct_%04x', ++$current_suffix;

  require Class::DBI;
  do {
    no strict 'refs';
    @{$new_class . '::ISA'} = qw(Class::DBI);
  };

  $new_class->connection($arg->{dsn}, 'icg', 'cjokerz');
  $new_class->table($arg->{table});

  my @columns = map { @$_ } values %note_columns;
  $new_class->columns(All => ('id', @columns));

  return $class_for->{ $arg->{dsn} }->{ $arg->{table} } = $new_class;
}

=head2 C< build_annotator >

  my $code = Object::Annotate->build_annotator(\%arg);

This builds the routine that will be installed as "annotate" in the importing
class.  It returns a coderef.

It takes the following arguments:

  class     - the constructed Class::DBI class to use for annotations
  obj_class - the class name to use for this class's log entries
  id_attr   - the method to use to get object ids; if a scalar ref, 
              the dereferenced string is used as a constant

=cut

sub build_annotator {
  my ($self, $arg) = @_;

  my $class     = $arg->{class};
  my $obj_class = $arg->{obj_class};
  my $id_attr   = $arg->{id_attr};

  my $annotator = sub {
    # This $arg purposefully shadows the previous; I don't want to enclose
    # those args. -- rjbs, 2006-01-05
    my ($self, $arg) = shift;

    my $id;
    if (ref $id_attr) {
      $id = $$id_attr;
    } else {
      $id = $self->$id_attr;
      Carp::croak "couldn't get id for $self via $id_attr" unless $id;
    }

    # build up only those attributes we said, in %note_columns, we'd allow to
    # be passed in manually
    my %attr;
    for (@{ $note_columns{manual} }) {
      next unless exists $arg->{$_};
      $attr{$_} = $arg->{$_};
    }

    use Data::Dump::Streamer; Dump(\%attr);

    $class->create({
      class     => $obj_class,
      object_id => $id,
      %attr,
    });

    # It's probably best to return nothing, for now. -- rjbs, 2006-01-05
    return;
  };

  return $annotator;
}

'2. see footnote #1';
