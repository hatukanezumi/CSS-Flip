

use strict;
use CSS::Janus;

my $subtests = 0;

my $obj;
my @trans = (
    'lr_tb' => 'rl_tb',
    'lr_tb' => 'tb_rl',
    'lr_tb' => 'tb_lr',
    'rl_tb' => 'tb_lr',
    'rl_tb' => 'tb_rl',
    'tb_lr' => 'tb_rl',
);

sub do5tests {
    my %in = ();
    $in{'lr_tb'} = shift;
    $in{'rl_tb'} = shift;
    $in{'tb_lr'} = shift;
    $in{'tb_rl'} = shift;
    my %opts = @_;

    $subtests++;

    my $i;
    for ($i = 0; $i < scalar @trans; ) {
	my $src = $trans[$i++];
	my $dest = $trans[$i++];
	next unless defined $in{$src} and defined $in{$dest};

	if ($src eq 'lr_tb' and $dest eq 'rl_tb') {
	    $obj = CSS::Janus->new(%opts);
	} else {
	    $obj = CSS::Yamaantaka->new($src => $dest, %opts);
	}
	is($obj->transform($in{$src}), $in{$dest},
	    "$subtests: $src => $dest: " . $obj->{'adaptor'}
	);
    }
}

1;
