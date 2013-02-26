#-*- perl -*-

use strict;
#use warnings;
use Test::More tests => 4;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;
my @args;

$testcase = 'border-top-left-radius: 1px';
$shouldbe = 'border-top-right-radius: 1px';
is($self->transform($testcase), $shouldbe);

$testcase = '-moz-border-radius-topright: 1px';
$shouldbe = '-moz-border-radius-topleft: 1px';
is($self->transform($testcase), $shouldbe);

$testcase = 'border-bottom-right-radius: 1px 2px';
$shouldbe = 'border-bottom-left-radius: 1px 2px';
is($self->transform($testcase), $shouldbe);

$testcase = '-moz-border-radius-bottomleft: 1px 2px';
$shouldbe = '-moz-border-radius-bottomright: 1px 2px';
is($self->transform($testcase), $shouldbe);

