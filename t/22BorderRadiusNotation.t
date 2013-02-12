#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 4;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

$testcase = ['border-radius: .25em 15px 0pt 0ex'];
$shouldbe = ['border-radius: 15px .25em 0ex 0pt'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['border-radius: 10px 15px 0px'];
$shouldbe = ['border-radius: 15px 10px 15px 0px'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['border-radius: 7px 8px'];
$shouldbe = ['border-radius: 8px 7px'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['border-radius: 5px'];
$shouldbe = ['border-radius: 5px'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

