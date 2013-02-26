#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 60; }

my %opts = (
    'swap_ltr_rtl_in_url'    => 0,
    'swap_left_right_in_url' => 0,
);

do5tests(
    'background: url(/foo/bar-left.png)',
    'background: url(/foo/bar-left.png)',
    'background: url(/foo/bar-left.png)',
    'background: url(/foo/bar-left.png)',
    %opts
);

do5tests(
    'background: url(/foo/left-bar.png)',
    'background: url(/foo/left-bar.png)',
    'background: url(/foo/left-bar.png)',
    'background: url(/foo/left-bar.png)',
    %opts
);

do5tests(
    'url("http://www.blogger.com/img/triangle_ltr.gif")',
    'url("http://www.blogger.com/img/triangle_ltr.gif")',
    'url("http://www.blogger.com/img/triangle_ltr.gif")',
    'url("http://www.blogger.com/img/triangle_ltr.gif")',
    %opts
);

do5tests(
    "url('http://www.blogger.com/img/triangle_ltr.gif')",
    "url('http://www.blogger.com/img/triangle_ltr.gif')",
    "url('http://www.blogger.com/img/triangle_ltr.gif')",
    "url('http://www.blogger.com/img/triangle_ltr.gif')",
    %opts
);

do5tests(
    "url('http://www.blogger.com/img/triangle_ltr.gif'  )",
    "url('http://www.blogger.com/img/triangle_ltr.gif'  )",
    "url('http://www.blogger.com/img/triangle_ltr.gif'  )",
    "url('http://www.blogger.com/img/triangle_ltr.gif'  )",
    %opts
);

do5tests(
    'background: url(/foo/bar.left.png)',
    'background: url(/foo/bar.left.png)',
    'background: url(/foo/bar.left.png)',
    'background: url(/foo/bar.left.png)',
    %opts
);

do5tests(
    'background: url(/foo/bar-rtl.png)',
    'background: url(/foo/bar-rtl.png)',
    'background: url(/foo/bar-rtl.png)',
    'background: url(/foo/bar-rtl.png)',
    %opts
);

do5tests(
    'background: url(/foo/bar-rtl.png); left: 10px',
    'background: url(/foo/bar-rtl.png); right: 10px',
    'background: url(/foo/bar-rtl.png); top: 10px',
    'background: url(/foo/bar-rtl.png); top: 10px',
    %opts
);

do5tests(
    'background: url(/foo/bar-right.png); direction: ltr',
    'background: url(/foo/bar-right.png); direction: ltr',
    'background: url(/foo/bar-right.png); direction: ltr',
    'background: url(/foo/bar-right.png); direction: ltr',
    %opts
);

do5tests(
    'background: url(/foo/bar-rtl_right.png);' . 'left:10px; direction: ltr',
    'background: url(/foo/bar-rtl_right.png);' . 'right:10px; direction: ltr',
    'background: url(/foo/bar-rtl_right.png);' . 'top:10px; direction: ltr',
    'background: url(/foo/bar-rtl_right.png);' . 'top:10px; direction: ltr',
    %opts
);

