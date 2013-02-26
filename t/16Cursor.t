#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 36; }

do5tests(
    'cursor: e-resize',
    'cursor: w-resize',
    'cursor: s-resize',
    'cursor: s-resize',
);

do5tests(
    'cursor: w-resize',
    'cursor: e-resize',
    'cursor: n-resize',
    'cursor: n-resize',
);

do5tests(
    'cursor: se-resize',
    'cursor: sw-resize',
    'cursor: se-resize',
    'cursor: sw-resize',
);

do5tests(
    'cursor: sw-resize',
    'cursor: se-resize',
    'cursor: ne-resize',
    'cursor: nw-resize',
);

do5tests(
    'cursor: ne-resize',
    'cursor: nw-resize',
    'cursor: sw-resize',
    'cursor: se-resize',
);

do5tests(
    'cursor: nw-resize',
    'cursor: ne-resize',
    'cursor: nw-resize',
    'cursor: ne-resize',
);

