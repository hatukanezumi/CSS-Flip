#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 42; }

# we don't want direction to be changed other than in body;
do5tests(
    'direction: ltr',
    'direction: ltr',
    'direction: ltr',
    'direction: ltr',
);

# we don't want direction to be changed other than in body;
do5tests(
    'direction: rtl',
    'direction: rtl',
    'direction: rtl',
    'direction: rtl',
);

# we don't want direction to be changed other than in body;
do5tests(
    'input { direction: ltr }',
    'input { direction: ltr }',
    'input { direction: ltr }',
    'input { direction: ltr }',
);

do5tests(
    'body { direction: ltr }',
    'body { direction: rtl }',
    'body { direction: ltr }',
    'body { direction: rtl }',
);

do5tests(
    'body { padding: 10px; direction: ltr; }',
    'body { padding: 10px; direction: rtl; }',
    'body { padding: 10px; direction: ltr; }',
    'body { padding: 10px; direction: rtl; }',
);

do5tests(
    'body { direction: ltr } .myClass { direction: ltr }',
    'body { direction: rtl } .myClass { direction: ltr }',
    'body { direction: ltr } .myClass { direction: ltr }',
    'body { direction: rtl } .myClass { direction: ltr }',
);

do5tests(
    "body{\n direction: ltr\n}",
    "body{\n direction: rtl\n}",
    "body{\n direction: ltr\n}",
    "body{\n direction: rtl\n}",
);

