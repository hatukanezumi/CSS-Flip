#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 6;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['cursor: e-resize'];
$shouldbe = ['cursor: w-resize'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['cursor: w-resize'];
$shouldbe = ['cursor: e-resize'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['cursor: se-resize'];
$shouldbe = ['cursor: sw-resize'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['cursor: sw-resize'];
$shouldbe = ['cursor: se-resize'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['cursor: ne-resize'];
$shouldbe = ['cursor: nw-resize'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['cursor: nw-resize'];
$shouldbe = ['cursor: ne-resize'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

