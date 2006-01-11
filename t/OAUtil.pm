package OAUtil;

use strict;
use warnings;

use DBI;
use Fatal;
use File::Slurp;

my $schema = read_file("sql/sqlite.sql");

my $db  = "t/notes.db";
my $dsn = "dbi:SQLite:dbname=$db";

sub build_empty_db {
  unlink $db if -e $db;
  my $dbh = DBI->connect($dsn, undef, undef);
  $dbh->do($schema);
}

{
  package Some::Object;
  use Object::Annotate {
    obj_class => 'thinger',
    dsn       => 'dbi:SQLite:dbname=t/notes.db',
    table     => 'annotations',
  };

  sub new { return bless {} }
  sub id { return $_[0] + 0 };
}

{
  package Some::Widget;
  use Object::Annotate {
    dsn       => 'dbi:SQLite:dbname=t/notes.db',
    table     => 'annotations',
  };

  sub new { return bless {} => shift }
  sub id { return $_[0] + 0 };
}

{
  package Some::Widget::Generic;
  our @ISA = qw(Some::Widget);
  use Object::Annotate {
    dsn       => 'dbi:SQLite:dbname=t/notes.db',
    table     => 'annotations',
    obj_class => 'widgeneric',
    id_attr   => \'generic',
  };
}

"true value";
