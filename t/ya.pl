

use strict;
use CSS::Janus;

my $janus;
my $ya;

sub do5tests {
    my $ltr_tb = shift;
    my $rtl_tb = shift;
    my $ttb_lr = shift;
    my $ttb_rl = shift;
    my %opts = @_;

    $janus = CSS::Janus->new(%opts);
    # mirror-h
    is($janus->transform($ltr_tb), $rtl_tb,
	"ltr-tb => rtl-tb: mirror-h")
	if defined $ltr_tb and defined $rtl_tb;
    # rotate-r
    is(CSS::Yamaantaka->new('ltr_tb' => 'ttb_rl', %opts)->transform($ltr_tb),
	$ttb_rl)
	if defined $ltr_tb and defined $ttb_rl;
    # mirror-tlbr
    is(CSS::Yamaantaka->new('ltr_tb' => 'ttb_lr', %opts)->transform($ltr_tb),
	$ttb_lr)
	if defined $ltr_tb and defined $ttb_lr;
    # rotate-l
    is(CSS::Yamaantaka->new('rtl_tb' => 'ttb_lr', %opts)->transform($rtl_tb),
	$ttb_lr, "rtl-tb => ttb-lr: rotate-l")
	if defined $rtl_tb and defined $ttb_lr;
    # mirror-trbl
    is(CSS::Yamaantaka->new('rtl_tb' => 'ttb_rl', %opts)->transform($rtl_tb),
        $ttb_rl, "rtl-tb => ttb-rl: mirror-trbl")
	if defined $rtl_tb and defined $ttb_rl;
    # mirror-v
    is(CSS::Yamaantaka->new('ttb_lr' => 'ttb_rl', %opts)->transform($ttb_lr),
	$ttb_rl);
}

1;
