#-*- perl -*-
#-*- coding: us-ascii -*-

package CSS::Yamaantaka::MirrorTL_BR;

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
	'top'    => 'left',
	'right'  => 'bottom',
	'bottom' => 'right',
	'left'   => 'top',
	}->{$direction} ||
	$direction;
}

sub fixCursorPositions {
    my $direction = $_[1];
    $direction =~ tr/nesw/wsen/;
    return $direction;
}

sub reorderFourPartNotation {
    shift;
    my @part = @_;
    @part = @part[3, 2, 1, 0];
    return @part;
}

sub reorderBorderRadiusSubparts {
    shift;
    my @part = @_;
    @part = @part[0, 3, 2, 1];
    return @part;
}

1;
