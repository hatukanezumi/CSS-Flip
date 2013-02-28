#-*- perl -*-

use strict;
#use warnings;
use Test::More;
require 't/ya.pl';

BEGIN { plan tests => 66; }

my %opts = (
    'swap_ltr_rtl_in_url'    => 1,
    'swap_left_right_in_url' => 1
);

do5tests(
    'background: url(/foo/bar-left.png)',
    'background: url(/foo/bar-right.png)',
    'background: url(/foo/bar-top.png)',
    'background: url(/foo/bar-top.png)',
    %opts
);

do5tests(
    'background: url(/foo/left-bar.png)',
    'background: url(/foo/right-bar.png)',
    'background: url(/foo/top-bar.png)',
    'background: url(/foo/top-bar.png)',
    %opts
);

do5tests(
    'url("http://www.blogger.com/img/triangle_ltr.gif")',
    'url("http://www.blogger.com/img/triangle_rtl.gif")',
    'url("http://www.blogger.com/img/triangle_ltr.gif")',
    'url("http://www.blogger.com/img/triangle_rtl.gif")',
    %opts
);

do5tests(
    "url('http://www.blogger.com/img/triangle_ltr.gif')",
    "url('http://www.blogger.com/img/triangle_rtl.gif')",
    "url('http://www.blogger.com/img/triangle_ltr.gif')",
    "url('http://www.blogger.com/img/triangle_rtl.gif')",
    %opts
);

do5tests(
    "url('http://www.blogger.com/img/triangle_ltr.gif'  )",
    "url('http://www.blogger.com/img/triangle_rtl.gif'  )",
    "url('http://www.blogger.com/img/triangle_ltr.gif'  )",
    "url('http://www.blogger.com/img/triangle_rtl.gif'  )",
    %opts
);

do5tests(
    'background: url(/foo/bar.left.png)',
    'background: url(/foo/bar.right.png)',
    'background: url(/foo/bar.top.png)',
    'background: url(/foo/bar.top.png)',
    %opts
);

do5tests(
    'background: url(/foo/bright.png)',
    'background: url(/foo/bright.png)',
    'background: url(/foo/bright.png)',
    'background: url(/foo/bright.png)',
    %opts
);

do5tests(
    'background: url(/foo/bar-rtl.png)',
    'background: url(/foo/bar-ltr.png)',
    'background: url(/foo/bar-rtl.png)',
    'background: url(/foo/bar-ltr.png)',
    %opts
);

do5tests(
    'background: url(/foo/bar-rtl.png); left: 10px',
    'background: url(/foo/bar-ltr.png); right: 10px',
    'background: url(/foo/bar-rtl.png); top: 10px',
    'background: url(/foo/bar-ltr.png); top: 10px',
    %opts
);

do5tests(
    'background: url(/foo/bar-right.png); direction: ltr',
    'background: url(/foo/bar-left.png); direction: ltr',
    'background: url(/foo/bar-bottom.png); direction: ltr',
    'background: url(/foo/bar-bottom.png); direction: ltr',
    %opts
);

do5tests(
    'background: url(/foo/bar-rtl_right.png);' . 'left:10px; direction: ltr',
    'background: url(/foo/bar-ltr_left.png);' . 'right:10px; direction: ltr',
    'background: url(/foo/bar-rtl_bottom.png);' . 'top:10px; direction: ltr',
    'background: url(/foo/bar-ltr_bottom.png);' . 'top:10px; direction: ltr',
    %opts
);

