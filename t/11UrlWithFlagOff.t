#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 10;

use CSS::Janus;

my $self = CSS::Janus->new;
my $testcase;
my $shouldbe;

my $swap_ltr_rtl_in_url    = 0;
my $swap_left_right_in_url = 0;

$testcase = ['background: url(/foo/bar-left.png)'];
$shouldbe = ['background: url(/foo/bar-left.png)'];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ['background: url(/foo/left-bar.png)'];
$shouldbe = ['background: url(/foo/left-bar.png)'];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ['url("http://www.blogger.com/img/triangle_ltr.gif")'];
$shouldbe = ['url("http://www.blogger.com/img/triangle_ltr.gif")'];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ["url('http://www.blogger.com/img/triangle_ltr.gif')"];
$shouldbe = ["url('http://www.blogger.com/img/triangle_ltr.gif')"];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ["url('http://www.blogger.com/img/triangle_ltr.gif'  )"];
$shouldbe = ["url('http://www.blogger.com/img/triangle_ltr.gif'  )"];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ['background: url(/foo/bar.left.png)'];
$shouldbe = ['background: url(/foo/bar.left.png)'];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ['background: url(/foo/bar-rtl.png)'];
$shouldbe = ['background: url(/foo/bar-rtl.png)'];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ['background: url(/foo/bar-rtl.png); left: 10px'];
$shouldbe = ['background: url(/foo/bar-rtl.png); right: 10px'];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase = ['background: url(/foo/bar-right.png); direction: ltr'];
$shouldbe = ['background: url(/foo/bar-right.png); direction: ltr'];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

$testcase =
    ['background: url(/foo/bar-rtl_right.png);' . 'left:10px; direction: ltr'
    ];
$shouldbe =
    ['background: url(/foo/bar-rtl_right.png);' . 'right:10px; direction: ltr'
    ];
is_deeply(
    $shouldbe,
    $self->ChangeLeftToRightToLeft(
	$testcase, $swap_ltr_rtl_in_url, $swap_left_right_in_url
    )
);

