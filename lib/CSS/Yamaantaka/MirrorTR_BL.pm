#-*- perl -*-
#-*- coding: us-ascii -*-

package CSS::Yamaantaka::MirrorTR_BL;

use strict;
#use warnings;
use base qw(
    CSS::Yamaantaka::_NoReverseLR
    CSS::Yamaantaka::_NoReverseGD
    CSS::Yamaantaka::_SwapHV
);

sub fixBoxDirectionPart {
    my $direction = $_[1];
    return {
	'top'    => 'right',
	'right'  => 'top',
	'bottom' => 'left',
	'left'   => 'bottom',
	}->{$direction} ||
	$direction;
}

sub fixCursorPositions {
    my $direction = $_[1];
    $direction =~ tr/nesw/enws/;
    return $direction;
}

sub reorderFourPartNotation {
    shift;
    my @part = @_;
    @part = @part[1, 0, 3, 2];
    return @part;
}

sub reorderBorderRadiusSubparts {
    shift;
    my @part = @_;
    @part = @part[2, 1, 0, 3];
    return @part;
}

1;
