#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

{
  package Some::Object;
  use Object::Annotate {
    obj_class => 'thinger',
    dsn       => 'dbi:Pg:dbname=icg;host=licorice.pobox.com;sslmode=prefer',
    table     => 'annotations',
    db_user   => 'icg',
    db_pass   => 'cjokerz',
    sequence  => 'annotations_id_seq',
  };

  sub id { return $_[0] + 0 };
}

my $object = bless {} => 'Some::Object';

isa_ok($object, 'Some::Object');
can_ok($object, 'annotate');

my $annotation_class = $object->annotation_class;
like(
  $annotation_class,
  qr/\AObject::Annotate::Construct_/,
  "object annotation class looks like what we expect",
);

$object->annotate({ event => "grand opening", comment => "colossal failure" });
