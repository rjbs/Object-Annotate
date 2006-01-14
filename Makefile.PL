
use strict;
use warnings;

use inc::Module::Install;
use File::Find;

name          ('Object-Annotate');
author        ('Ricardo SIGNES <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/Object/Annotate.pm');

requires('Class::DBI'         => 0.00);
requires('UNIVERSAL::moniker' => 0.01);
requires('Sub::Install'       => 0.03);

my $files = '';
find( sub { $files .= " $File::Find::name" if -f && /\.t$/ }, "t" );

tests         ($files);

sign(1);

WriteAll();
