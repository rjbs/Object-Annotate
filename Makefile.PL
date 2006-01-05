use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'Object-Annotate',
	AUTHOR              => 'Ricardo SIGNES <rjbs@cpan.org>',
	VERSION_FROM        => 'lib/Object/Annotate.pm',
	PL_FILES            => {},
	PREREQ_PM => {
		'Class::DBI'         => 0.00,
    'UNIVERSAL::moniker' => 0.01,
    'Sub::Install'       => 0.03,
	},
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'Object-Annotate-*' },
);
