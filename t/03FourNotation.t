#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 37; }

do5tests(
    'padding: .25em 15px 0pt 0ex',
    'padding: .25em 0ex 0pt 15px',
    'padding: 0ex 0pt 15px .25em',
    'padding: 0ex .25em 15px 0pt',
);

do5tests(
    'margin: 1px -4px 3px 2px',
    'margin: 1px 2px 3px -4px',
    'margin: 2px 3px -4px 1px',
    'margin: 2px 1px -4px 3px',
);

do5tests(
    'padding:0 15px .25em 0',
    'padding:0 0 .25em 15px',
    'padding:0 .25em 15px 0',
    'padding:0 0 15px .25em',
);

do5tests(
    'padding: 1px 4.1grad 3px 2%',
    'padding: 1px 2% 3px 4.1grad',
    'padding: 2% 3px 4.1grad 1px',
    'padding: 2% 1px 4.1grad 3px',
);

do5tests(
    'padding: 1px 2px 3px auto',
    'padding: 1px auto 3px 2px',
    'padding: auto 3px 2px 1px',
    'padding: auto 1px 2px 3px',
);

do5tests(
    'padding: 1px inherit 3px auto',
    'padding: 1px auto 3px inherit',
    'padding: auto 3px inherit 1px',
    'padding: auto 1px inherit 3px',
);

# not really four notation
my $testcase = '#settings td p strong';
is(CSS::Janus->new->transform($testcase), $testcase);

