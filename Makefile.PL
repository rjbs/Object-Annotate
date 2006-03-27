
use strict;
use warnings;

use inc::Module::Install;

name          ('Object-Annotate');
author        ('Ricardo SIGNES <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/Object/Annotate.pm');

requires('Class::DBI'         => 0.00);
requires('UNIVERSAL::moniker' => 0.01);
requires('Sub::Exporter'      => 0.92);

sign(1);

WriteAll();
