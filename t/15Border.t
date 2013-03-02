#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests(
    'border-left: bar',
    'border-right: bar',
    'border-top: bar',
    'border-top: bar',
);

do5tests(
    'border-right: bar',
    'border-left: bar',
    'border-bottom: bar',
    'border-bottom: bar',
);

