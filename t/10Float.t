#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 2;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['float: right'];
$shouldbe = ['float: left'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['float: left'];
$shouldbe = ['float: right'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

