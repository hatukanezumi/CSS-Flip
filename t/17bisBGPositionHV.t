#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 24; }

do5tests(
    'background: url(/foo/bar.png) top left',
    'background: url(/foo/bar.png) top right',
    'background: url(/foo/bar.png) top left',
    'background: url(/foo/bar.png) top right',
);

do5tests(
    'background: url(/foo/bar.png) top right',
    'background: url(/foo/bar.png) top left',
    'background: url(/foo/bar.png) bottom left',
    'background: url(/foo/bar.png) bottom right',
);

do5tests(
    'background-position: top left',
    'background-position: top right',
    'background-position: top left',
    'background-position: top right',
);

do5tests(
    'background-position: top right',
    'background-position: top left',
    'background-position: bottom left',
    'background-position: bottom right',
);

