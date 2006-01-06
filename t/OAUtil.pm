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
