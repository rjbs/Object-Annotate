package OAUtil;

use strict;
use warnings;

use DBI;
use Fatal;
use File::Slurp;

my ($schema, $db, $dsn, @db_pair);

BEGIN { 
  $schema = read_file("sql/sqlite.sql");

  $db  = "t/notes.db";
  $dsn = "dbi:SQLite:dbname=$db";

  @db_pair = (
    db => { 
      dsn   => $dsn,
      table => 'annotations',
    }
  );
}

sub build_empty_db {
  unlink $db if -e $db;
  my $dbh = DBI->connect($dsn, undef, undef);
  $dbh->do($schema);
}

{
  package Some::Object;
  use Object::Annotate (
    @db_pair,
    obj_class => 'thinger',
  );

  sub new { return bless {} }
  sub id { return $_[0] + 0 };
}

{
  package Some::Widget;
  use Object::Annotate @db_pair;

  sub new { return bless {} => shift }
  sub id { return $_[0] + 0 };
}

{
  package Some::Widget::Generic;
  our @ISA = qw(Some::Widget);
  use Object::Annotate (
    @db_pair,
    obj_class => 'widgeneric',
    id_attr   => \'generic',
  );
}

"true value";
