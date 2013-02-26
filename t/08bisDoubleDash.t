#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests(
    'border-top-color: red',
    'border-top-color: red',
    'border-left-color: red',
    'border-right-color: red',
);

do5tests(
    'border-bottom-color: red',
    'border-bottom-color: red',
    'border-right-color: red',
    'border-left-color: red',
);

