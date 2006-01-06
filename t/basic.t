#!perl -T

use strict;
use warnings;

use lib 't';
use OAUtil;

use Test::More 'no_plan';

BEGIN { OAUtil->build_empty_db; }

{
  package Some::Object;
  use Object::Annotate {
    obj_class => 'thinger',
    dsn       => 'dbi:SQLite:dbname=t/notes.db',
    table     => 'annotations',
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
