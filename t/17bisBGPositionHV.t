#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 24; }

do5tests(
    'background: url(/foo/bar.png) left top',
    'background: url(/foo/bar.png) right top',
    'background: url(/foo/bar.png) left top',
    'background: url(/foo/bar.png) right top',
);

do5tests(
    'background: url(/foo/bar.png) right top',
    'background: url(/foo/bar.png) left top',
    'background: url(/foo/bar.png) left bottom',
    'background: url(/foo/bar.png) right bottom',
);

do5tests(
    'background-position: left top',
    'background-position: right top',
    'background-position: left top',
    'background-position: right top',
);

do5tests(
    'background-position: right top',
    'background-position: left top',
    'background-position: left bottom',
    'background-position: right bottom',
);

