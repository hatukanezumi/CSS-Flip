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
    '.column-top { float: left }',
    '.column-top { float: right }',
);
do5tests(
    '.column-top { float: left }',
    undef,
    '.column-top { float: left }',
    '.column-top { float: left }',
);
do5tests(
    undef,
    '.column-top { float: left }',
    '.column-top { float: left }',
    '.column-top { float: left }',
);

do5tests(
    '#bbottom-light { float: left }',
    '#bbottom-light { float: right }',
);
do5tests(
    '#bbottom-light { float: left }',
    undef,
    '#bbottom-light { float: left }',
    '#bbottom-light { float: left }',
);
do5tests(
    undef,
    '#bbottom-light { float: left }',
    '#bbottom-light { float: left }',
    '#bbottom-light { float: left }',
);

do5tests(
    'a.top:hover { float: left }',
    'a.top:hover { float: right }',
);
do5tests(
    'a.top:hover { float: left }',
    undef,
    'a.top:hover { float: left }',
    'a.top:hover { float: left }',
);
do5tests(
    undef,
    'a.top:hover { float: left }',
    'a.top:hover { float: left }',
    'a.top:hover { float: left }',
);

##tests newlines;
#do5tests(
#    "#bbottom-top,\n.test-me { float: left }",
#    "#bbottom-top,\n.test-me { float: right }",
#    "#bbottom-top,\n.test-me { float: left }",
#    "#bbottom-top,\n.test-me { float: left }",
#);

#tests newlines;
do5tests(
    "#bbottom-top,\n.test-me { float: left }",
    "#bbottom-top,\n.test-me { float: right }",
);
do5tests(
    "#bbottom-top,\n.test-me { float: left }",
    undef,
    "#bbottom-top,\n.test-me { float: left }",
    "#bbottom-top,\n.test-me { float: left }",
);
do5tests(
    undef,
    "#bbottom-top,\n.test-me { float: left }",
    "#bbottom-top,\n.test-me { float: left }",
    "#bbottom-top,\n.test-me { float: left }",
);

#tests multiple names and commas;
do5tests(
    'div.toppill, div.toppillon {margin-right: 0 !important}',
    'div.toppill, div.toppillon {margin-left: 0 !important}',
    'div.toppill, div.toppillon {margin-bottom: 0 !important}',
    'div.toppill, div.toppillon {margin-bottom: 0 !important}',
);

do5tests(
    'div.top > span.bottom+span.top { float: left }',
    'div.top > span.bottom+span.top { float: right }',
);
do5tests(
    'div.top > span.bottom+span.top { float: left }',
    undef,
    'div.top > span.bottom+span.top { float: left }',
    'div.top > span.bottom+span.top { float: left }',
);
do5tests(
    undef,
    'div.top > span.bottom+span.top { float: left }',
    'div.top > span.bottom+span.top { float: left }',
    'div.top > span.bottom+span.top { float: left }',
);

do5tests(
    '.thisclass .top .myclass {background:#fff;}',
    '.thisclass .top .myclass {background:#fff;}',
    '.thisclass .top .myclass {background:#fff;}',
    '.thisclass .top .myclass {background:#fff;}',
);

do5tests(
    '.thisclass .top .myclass #myid {background:#fff;}',
    '.thisclass .top .myclass #myid {background:#fff;}',
    '.thisclass .top .myclass #myid {background:#fff;}',
    '.thisclass .top .myclass #myid {background:#fff;}',
);
