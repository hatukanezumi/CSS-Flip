#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 29; }

use CSS::Janus;
my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;
my @args;

@args     = qw(1px 2px 3px 4px);
$shouldbe = '2px 1px 4px 3px';
is( CSS::Yamaantaka::reorderBorderRadiusPart(
	'CSS::Yamaantaka::MirrorH', @args
    ),
    $shouldbe
);

@args     = qw(1px 2px 3px);
$shouldbe = '2px 1px 2px 3px';
is( CSS::Yamaantaka::reorderBorderRadiusPart(
	'CSS::Yamaantaka::MirrorH', @args
    ),
    $shouldbe
);

@args     = qw(1px 2px);
$shouldbe = '2px 1px';
is( CSS::Yamaantaka::reorderBorderRadiusPart(
	'CSS::Yamaantaka::MirrorH', @args
    ),
    $shouldbe
);

@args     = qw(1px);
$shouldbe = '1px';
is( CSS::Yamaantaka::reorderBorderRadiusPart(
	'CSS::Yamaantaka::MirrorH', @args
    ),
    $shouldbe
);

@args =
    ('X', '', ': ', '1px', '2px', '3px', '4px', '5px', '6px', undef, '7px');
$shouldbe = 'border-radius: 2px 1px 4px 3px / 6px 5px 6px 7px';
is($self->reorderBorderRadius(@args), $shouldbe);

do5tests(
    'border-radius: 1px 2px 3px 4px / 5px 6px 7px 8px',
    'border-radius: 2px 1px 4px 3px / 6px 5px 8px 7px',
    'border-radius: 5px 8px 7px 6px / 1px 4px 3px 2px',
    'border-radius: 8px 5px 6px 7px / 4px 1px 2px 3px',
);

do5tests(
    'border-radius: 1px 2px 3px 4px / 5px 6px 7px',
    'border-radius: 2px 1px 4px 3px / 6px 5px 6px 7px',
    'border-radius: 5px 6px 7px / 1px 4px 3px 2px',
    'border-radius: 6px 5px 6px 7px / 4px 1px 2px 3px',
);

do5tests(
    'border-radius: 1px 2px 3px 4px / 5px 6px',
    'border-radius: 2px 1px 4px 3px / 6px 5px',
    'border-radius: 5px 6px / 1px 4px 3px 2px',
    'border-radius: 6px 5px / 4px 1px 2px 3px',
);

do5tests(
    'border-radius: 1px 2px 3px 4px / 5px',
    'border-radius: 2px 1px 4px 3px / 5px',
    'border-radius: 5px / 1px 4px 3px 2px',
    'border-radius: 5px / 4px 1px 2px 3px',
);
