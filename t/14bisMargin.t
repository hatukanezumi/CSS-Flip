#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests(
    'margin-top: bar',
    'margin-top: bar',
    'margin-left: bar',
    'margin-right: bar',
);

do5tests(
    'margin-bottom: bar',
    'margin-bottom: bar',
    'margin-right: bar',
    'margin-left: bar',
);

