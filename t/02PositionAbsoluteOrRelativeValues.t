#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 1;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['left: 10px'];
$shouldbe = ['right: 10px'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

