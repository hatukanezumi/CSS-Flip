#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 24; }

do5tests(
    'background: url(/foo/bar.png) top left',
    'background: url(/foo/bar.png) top right',
    'background: url(/foo/bar.png) left top',
    'background: url(/foo/bar.png) right top',
);

do5tests(
    'background: url(/foo/bar.png) top right',
    'background: url(/foo/bar.png) top left',
    'background: url(/foo/bar.png) left bottom',
    'background: url(/foo/bar.png) right bottom',
);

do5tests(
    'background-position: top left',
    'background-position: top right',
    'background-position: left top',
    'background-position: right top',
);

do5tests(
    'background-position: top right',
    'background-position: top left',
    'background-position: left bottom',
    'background-position: right bottom',
);

