#-*- perl -*-
#-*- coding: us-ascii -*-

package CSS::Yamaantaka::RotateR;

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
	'top'    => 'right',
	'right'  => 'bottom',
	'bottom' => 'left',
	'left'   => 'top',
	}->{$direction} ||
	$direction;
}

sub fixCursorPositions {
    my $direction = $_[1];
    $direction =~ tr/nesw/eswn/;
    return $direction;
}

sub reorderFourPartNotation {
    shift;
    my @part = @_;
    @part = @part[3, 0, 1, 2];
    return @part;
}

sub reorderBorderRadiusSubparts {
    shift;
    my @part = @_;
    @part = @part[3, 0, 1, 2];
    return @part;
}

1;
