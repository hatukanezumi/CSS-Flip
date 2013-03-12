#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 24; }

do5tests(
    'border-top-left-radius: 1px',
    'border-top-right-radius: 1px',
    'border-top-left-radius: 1px',
    'border-top-right-radius: 1px',
);

do5tests(
    '-moz-border-radius-topright: 1px',
    '-moz-border-radius-topleft: 1px',
    '-moz-border-radius-bottomleft: 1px',
    '-moz-border-radius-bottomright: 1px',
);

do5tests(
    'border-bottom-right-radius: 1px 2px',
    'border-bottom-left-radius: 1px 2px',
    'border-bottom-right-radius: 2px 1px',
    'border-bottom-left-radius: 2px 1px',
);

do5tests(
    '-moz-border-radius-bottomleft: 1px 2px',
    '-moz-border-radius-bottomright: 1px 2px',
    '-moz-border-radius-topright: 2px 1px',
    '-moz-border-radius-topleft: 2px 1px',
);

