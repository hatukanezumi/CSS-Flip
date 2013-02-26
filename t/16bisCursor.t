#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests(
    'cursor: nwse-resize',
    'cursor: nesw-resize',
    'cursor: nwse-resize',
    'cursor: nesw-resize',
);

do5tests(
    'cursor: nesw-resize',
    'cursor: nwse-resize',
    'cursor: nesw-resize',
    'cursor: nwse-resize',
);

