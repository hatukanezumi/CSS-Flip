#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 9;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

# Makes sure we don't unnecessarily destroy classnames with tokens in them.
#
# Despite the fact that that is a bad classname in CSS, we don't want to
# break anybody.

$testcase = ['.column-left { float: left }'];
$shouldbe = ['.column-left { float: right }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['#bright-light { float: left }'];
$shouldbe = ['#bright-light { float: right }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['a.left:hover { float: left }'];
$shouldbe = ['a.left:hover { float: right }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

#tests newlines;
$testcase = ['#bright-left,\n.test-me { float: left }'];
$shouldbe = ['#bright-left,\n.test-me { float: right }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

#tests newlines;
$testcase = ['#bright-left,', '.test-me { float: left }'];
$shouldbe = ['#bright-left,', '.test-me { float: right }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

#tests multiple names and commas;
$testcase = ['div.leftpill, div.leftpillon {margin-right: 0 !important}'];
$shouldbe = ['div.leftpill, div.leftpillon {margin-left: 0 !important}'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['div.left > span.right+span.left { float: left }'];
$shouldbe = ['div.left > span.right+span.left { float: right }'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['.thisclass .left .myclass {background:#fff;}'];
$shouldbe = ['.thisclass .left .myclass {background:#fff;}'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

$testcase = ['.thisclass .left .myclass #myid {background:#fff;}'];
$shouldbe = ['.thisclass .left .myclass #myid {background:#fff;}'];
is_deeply($shouldbe, $self->ChangeLeftToRightToLeft($testcase));

