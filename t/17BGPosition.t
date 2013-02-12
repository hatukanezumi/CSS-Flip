#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 4;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['background: url(/foo/bar.png) top left'];
$shouldbe = ['background: url(/foo/bar.png) top right'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background: url(/foo/bar.png) top right'];
$shouldbe = ['background: url(/foo/bar.png) top left'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background-position: top left'];
$shouldbe = ['background-position: top right'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background-position: top right'];
$shouldbe = ['background-position: top left'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

