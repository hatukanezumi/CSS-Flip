#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 2;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['margin-left: bar'];
$shouldbe = ['margin-right: bar'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['margin-right: bar'];
$shouldbe = ['margin-left: bar'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

