#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 2;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['border-left-color: red'];
$shouldbe = ['border-right-color: red'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['border-right-color: red'];
$shouldbe = ['border-left-color: red'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

# This is for compatibility strength, in reality CSS has no properties;
# that are currently like this.;
