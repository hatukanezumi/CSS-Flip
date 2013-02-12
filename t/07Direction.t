#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 7;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

# we don't want direction to be changed other than in body;
$testcase = ['direction: ltr'];
$shouldbe = ['direction: ltr'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

# we don't want direction to be changed other than in body;
$testcase = ['direction: rtl'];
$shouldbe = ['direction: rtl'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

# we don't want direction to be changed other than in body;
$testcase = ['input { direction: ltr }'];
$shouldbe = ['input { direction: ltr }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['body { direction: ltr }'];
$shouldbe = ['body { direction: rtl }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['body { padding: 10px; direction: ltr; }'];
$shouldbe = ['body { padding: 10px; direction: rtl; }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['body { direction: ltr } .myClass { direction: ltr }'];
$shouldbe = ['body { direction: rtl } .myClass { direction: ltr }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['body{\n direction: ltr\n}'];
$shouldbe = ['body{\n direction: rtl\n}'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

