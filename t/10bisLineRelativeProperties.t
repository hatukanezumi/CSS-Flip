#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 12; }

do5tests('float: right', undef, 'float: right', 'float: right',);

do5tests('float: left', undef, 'float: left', 'float: left',);

do5tests(undef, 'float: right', 'float: right', 'float: right',);

do5tests(undef, 'float: left', 'float: left', 'float: left',);

