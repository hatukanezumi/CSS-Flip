#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests(
    'padding-right: bar',
    'padding-left: bar',
    'padding-bottom: bar',
    'padding-bottom: bar',
);

do5tests(
    'padding-left: bar',
    'padding-right: bar',
    'padding-top: bar',
    'padding-top: bar',
);

