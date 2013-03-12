#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 53; }

# Makes sure we don't unnecessarily destroy classnames with tokens in them.
#
# Despite the fact that that is a bad classname in CSS, we don't want to
# break anybody.

do5tests(
    '.column-left { float: left }',
    '.column-left { float: right }',
);
do5tests(
    '.column-left { float: left }',
    undef,
    '.column-left { float: left }',
    '.column-left { float: left }',
);
do5tests(
    undef,
    '.column-left { float: left }',
    '.column-left { float: left }',
    '.column-left { float: left }',
);

do5tests(
    '#bright-light { float: left }',
    '#bright-light { float: right }',
);
do5tests(
    '#bright-light { float: left }',
    undef,
    '#bright-light { float: left }',
    '#bright-light { float: left }',
);
do5tests(
    undef,
    '#bright-light { float: left }',
    '#bright-light { float: left }',
    '#bright-light { float: left }',
);

do5tests(
    'a.left:hover { float: left }',
    'a.left:hover { float: right }',
);
do5tests(
    'a.left:hover { float: left }',
    undef,
    'a.left:hover { float: left }',
    'a.left:hover { float: left }',
);
do5tests(
    undef,
    'a.left:hover { float: left }',
    'a.left:hover { float: left }',
    'a.left:hover { float: left }',
);

##tests newlines;
#do5tests(
#    "#bright-left,\n.test-me { float: left }",
#    "#bright-left,\n.test-me { float: right }",
#    "#bright-left,\n.test-me { float: left }",
#    "#bright-left,\n.test-me { float: left }",
#);

#tests newlines;
do5tests(
    "#bright-left,\n.test-me { float: left }",
    "#bright-left,\n.test-me { float: right }",
);
do5tests(
    "#bright-left,\n.test-me { float: left }",
    undef,
    "#bright-left,\n.test-me { float: left }",
    "#bright-left,\n.test-me { float: left }",
);
do5tests(
    undef,
    "#bright-left,\n.test-me { float: left }",
    "#bright-left,\n.test-me { float: left }",
    "#bright-left,\n.test-me { float: left }",
);

#tests multiple names and commas;
do5tests(
    'div.leftpill, div.leftpillon {margin-right: 0 !important}',
    'div.leftpill, div.leftpillon {margin-left: 0 !important}',
    'div.leftpill, div.leftpillon {margin-bottom: 0 !important}',
    'div.leftpill, div.leftpillon {margin-bottom: 0 !important}',
);

do5tests(
    'div.left > span.right+span.left { float: left }',
    'div.left > span.right+span.left { float: right }',
);
do5tests(
    'div.left > span.right+span.left { float: left }',
    undef,
    'div.left > span.right+span.left { float: left }',
    'div.left > span.right+span.left { float: left }',
);
do5tests(
    undef,
    'div.left > span.right+span.left { float: left }',
    'div.left > span.right+span.left { float: left }',
    'div.left > span.right+span.left { float: left }',
);

do5tests(
    '.thisclass .left .myclass {background:#fff;}',
    '.thisclass .left .myclass {background:#fff;}',
    '.thisclass .left .myclass {background:#fff;}',
    '.thisclass .left .myclass {background:#fff;}',
);

do5tests(
    '.thisclass .left .myclass #myid {background:#fff;}',
    '.thisclass .left .myclass #myid {background:#fff;}',
    '.thisclass .left .myclass #myid {background:#fff;}',
    '.thisclass .left .myclass #myid {background:#fff;}',
);

