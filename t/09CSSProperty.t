#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 2;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['alright: 10px'];
$shouldbe = ['alright: 10px'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['alleft: 10px'];
$shouldbe = ['alleft: 10px'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

