#-*- perl -*-
#-*- coding: us-ascii -*-

package CSS::Yamaantaka::RotateL;

use strict;
#use warnings;
use base qw(
    CSS::Yamaantaka::_NoReverseLR
    CSS::Yamaantaka::_ReverseGD
    CSS::Yamaantaka::_SwapHV
);

sub fixBoxDirectionPart {
    my $direction = $_[1];
    return {
	'top'    => 'left',
	'right'  => 'top',
	'bottom' => 'right',
	'left'   => 'bottom',
	}->{$direction} ||
	$direction;
}

sub fixCursorPositions {
    my $direction = $_[1];
    $direction =~ tr/nesw/wnes/;
    return $direction;
}

sub reorderFourPartNotation {
    shift;
    my @part = @_;
    @part = @part[1, 2, 3, 0];
    return @part;
}

sub reorderBorderRadiusSubparts {
    shift;
    my @part = @_;
    @part = @part[1, 2, 3, 0];
    return @part;
}

1;
