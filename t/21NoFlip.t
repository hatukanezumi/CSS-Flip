#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 10;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

# Tests the /* @noflip */ annotation on classnames.
$testcase = ['/* @noflip */ div { float: left; }'];
$shouldbe = ['/* @noflip */ div { float: left; }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['/* @noflip */ div, .notme { float: left; }'];
$shouldbe = ['/* @noflip */ div, .notme { float: left; }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['/* @noflip */ div { float: left; } div { float: left; }'];
$shouldbe = ['/* @noflip */ div { float: left; } div { float: right; }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['/* @noflip */\ndiv { float: left; }\ndiv { float: left; }'];
$shouldbe = ['/* @noflip */\ndiv { float: left; }\ndiv { float: right; }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

# Test @noflip on single rules within classes
$testcase = ['div { float: left; /* @noflip */ float: left; }'];
$shouldbe = ['div { float: right; /* @noflip */ float: left; }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['div\n{ float: left;\n/* @noflip */\n float: left;\n }'];
$shouldbe = ['div\n{ float: right;\n/* @noflip */\n float: left;\n }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['div\n{ float: left;\n/* @noflip */\n text-align: left\n }'];
$shouldbe = ['div\n{ float: right;\n/* @noflip */\n text-align: left\n }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['div\n{ /* @noflip */\ntext-align: left;\nfloat: left\n  }'];
$shouldbe = ['div\n{ /* @noflip */\ntext-align: left;\nfloat: right\n  }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['/* @noflip */div{float:left;text-align:left;}div{float:left}'];
$shouldbe = ['/* @noflip */div{float:left;text-align:left;}div{float:right}'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['/* @noflip */', 'div{float:left;text-align:left;}a{foo:left}'];
$shouldbe = ['/* @noflip */', 'div{float:left;text-align:left;}a{foo:right}'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

