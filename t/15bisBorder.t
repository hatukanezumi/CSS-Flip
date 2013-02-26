#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests(
    'border-top: bar',
    'border-top: bar',
    'border-left: bar',
    'border-right: bar',
);

do5tests(
    'border-bottom: bar',
    'border-bottom: bar',
    'border-right: bar',
    'border-left: bar',
);

