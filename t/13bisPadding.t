#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests(
    'padding-top: bar',
    'padding-top: bar',
    'padding-left: bar',
    'padding-right: bar',
);

do5tests(
    'padding-bottom: bar',
    'padding-bottom: bar',
    'padding-right: bar',
    'padding-left: bar',
);

