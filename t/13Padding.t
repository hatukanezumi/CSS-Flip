#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 2;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['padding-right: bar'];
$shouldbe = ['padding-left: bar'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['padding-left: bar'];
$shouldbe = ['padding-right: bar'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

