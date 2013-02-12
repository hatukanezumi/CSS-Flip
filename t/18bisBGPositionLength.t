#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 8;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['background-position: 0 40%'];
$shouldbe = ['background-position: 100% 40%'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background-position: 0 0'];
$shouldbe = ['background-position: 100% 0'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background-position: 0 auto'];
$shouldbe = ['background-position: 100% auto'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background-position-x: 0'];
$shouldbe = ['background-position-x: 100%'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background-position-y: 0'];
$shouldbe = ['background-position-y: 0'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['background:url(../foo-bar_baz.2008.gif) no-repeat 0 50%'];
$shouldbe = ['background:url(../foo-bar_baz.2008.gif) no-repeat 100% 50%'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['.test { background: 0 20% } .test2 { background: 0 30% }'];
$shouldbe =
    ['.test { background: 100% 20% } .test2 { background: 100% 30% }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['.test { background: 0 20% } .test2 { background: 0 30% }'];
$shouldbe =
    ['.test { background: 100% 20% } .test2 { background: 100% 30% }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

