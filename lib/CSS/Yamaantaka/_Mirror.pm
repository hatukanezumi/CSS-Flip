#-*- perl -*-
#-*- coding: us-ascii -*-

package CSS::Yamaantaka::_Mirror;

use strict;
#use warnings;

sub fixBoxDirectionPart {
    my $direction = $_[1];
    return {
	'right' => 'left',
	'left'  => 'right',
	}->{$direction} ||
	$direction;
}

sub fixCursorPositions {
    my $direction = $_[1];
    $direction =~ tr/ew/we/;
    return $direction;
}

sub reorderFourPartNotation {
    shift;
    my @part = @_;
    @part = @part[0, 3, 2, 1];
    return @part;
}

sub reorderBorderRadiusSubparts {
    shift;
    my @part = @_;
    @part = @part[1, 0, 3, 2];
    return @part;
}

1;
