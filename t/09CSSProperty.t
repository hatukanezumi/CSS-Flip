#-*- perl -*-

use strict;
#use warnings;
use Test::More tests => 2;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

# This is for compatibility strength, in reality CSS has no properties
# that are currently like this.

$testcase = 'alright: 10px';
$shouldbe = 'alright: 10px';
is($self->transform($testcase), $shouldbe);

$testcase = 'alleft: 10px';
$shouldbe = 'alleft: 10px';
is($self->transform($testcase), $shouldbe);

