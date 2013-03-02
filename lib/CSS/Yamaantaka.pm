#-*- perl -*-
#-*- coding: us-ascii -*-

=head1 NAME

CSS::Yamaantaka - Converts direction of Cascading Style Sheet (CSS)

=head1 SYNOPSIS

  use CSS::Yamaantaka;
  
  $ya = CSS::Yamaantaka->new('lr_tb' => 'tb_rl');
  $css_source_vertical_rl = $ya->transform($css_source);

=head1 DESCRIPTION

As YamE<257>ntaka has many legs, texts can run in various directions:
left to right and right to left horizontally; vertically with lines
extending right to left and left to right.

CSS::Yamaantaka replaces things directed to "left" or "horizontal-tb" in a
Cascading Style Sheet (CSS) file such as float, padding, margin with
values directed to "right" or "vertical-rl", and so on.

=head2 Transforming directions

Four directions of documents are supported:

=over 4

=item lr-tb

The direction specified by
C<{ direction: ltr; writing-mode: horizontal-tb; }>.
For example, most Western writing systems employ it.

=item rl-tb

The direction specified by
C<{ direction: rtl; writing-mode: horizontal-tb; }>.
For example, some Middle Eastern writing systems employ it.

=item tb-lr

The direction specified by
C<{ writing-mode: vertical-lr; }>.
For example, several North Asian writing systems employ it.

=item lr-tb

The direction specified by
C<{ writing-mode: vertical-rl; }>.
East Asian writing systems with vertical layout employ it.

=back

This module chooses transformation by source & resulting directions:

  +-----------+-------------+-------------+-------------+--------------+
  | from \ to | lr-tb       : rl-tb       : tb-lr       : tb-rl        |
  +-----------+-------------+-------------+-------------+--------------+
  | lr-tb     |      -      : MirrorH     : MirrorTL_BR : RotateR      |
  | rl-tb     | MirrorH     :      -      : RotateL*    : MirrorTR_BL* |
  | tb-lr     | MirrorTL_BR : RotateR     :      -      : MirrorV      |
  | tb-rl     | RotateL     : MirrorTR_BL : MirrorV     :       -      |
  +-----------+-------------+-------------+-------------+--------------+
   * Assumed text-orientation: sideways-left.

Each transformation changes line-relative box directions ("right" / "left" of
text-align, float and clear, and "top" / "bottom" of vertical-align), physical
box directions ("top" / "right" / "bottom" / "left"), global directions
specified by body element ("ltr" / "rtl") and direction swapping (horizontal /
vertical) as below:

  +-------------+-----------+--------------------------+--------+------+
  |             | line-rel. | box directions           : g. dir : h/v  |
  +-------------+-----------+--------------------------+--------+------+
  | MirrorH     | revert h. : revert horizontally      : revert :   -  |
  | MirrorV     |     -     : revert horizontally      : revert :   -  |
  | RotateR     |     -     : rotate clockwise         : revert : swap |
  | RotateL     |     -     : rotate counter-clockwise : revert : swap |
  | MirrorTL_BR |     -     : revert with tl-br axis   :    -   : swap |
  | MirrorTR_BL |     -     : revert with tr-bl axis   :    -   : swap |
  +-------------+-----------+--------------------------+--------+------+

Currently, this module won't fix line-relative text directions
("rtl" / "ltr").

=cut

use 5.005;    # qr{} and $10 are required.

package CSS::Yamaantaka;

use strict;
#use warnings;
use Carp qw(carp croak);
use CSS::Yamaantaka::Consts;

# To be compatible with Perl 5.5.
use vars qw($VERSION $BASE_REVISION);
$VERSION       = '0.04_01';
$BASE_REVISION = 'http://cssjanus.googlecode.com/svn/trunk@31';

=head2 Constructor

=over 4

=item new ( SRC => DEST, [ options... ] )

Creates new CSS::Yamaantaka object.

SRC and DEST are the original and resulting directions.
Available directions are
C<'lr_tb'>, C<'rl_tb'>, C<'tb_lr'> and C<'tb_rl'>.
Their synonyms are C<'ltr'>, C<'rtl'>, C<'vertical-lr'> and C<'vertical-rl'>,
respectively.

Following options are available.

=over 4

=item flip_url =E<gt> 0|1

Fixes "top"/"right"/"bottom"/"left" string within URLs.
Default is C<0>, won't fix.

=item swap_ltr_rtl_in_url =E<gt> 0|1

Fixes "ltr"/"rtl" string within URLs, if needed.
Default is C<0>, won't fix.

=item ignore_bad_bgp =E<gt> 0|1

Ignores unmirrorable background-position values.
Default is C<0>, won't ignore and will croak it.

=item flip_cursor =E<gt> 0|1

Fixes positions "n"/"e"/"s"/"w" and so on within cursor properties.
Default is C<1>, will fix.

=back

=back

=cut

my %defaults = (
    'flip_url'            => 0,
    'swap_ltr_rtl_in_url' => 0,
    'ignore_bad_bgp'      => 0,
    'flip_cursor'         => 1,
);

my %dir_synonym = (
    'ltr'         => 'lr_tb',
    'rtl'         => 'rl_tb',
    'vertical-lr' => 'tb_lr',
    'vertical-rl' => 'tb_rl',
);

my %adaptor = (
    "lr_tb$;rl_tb" => 'MirrorH',
    "rl_tb$;lr_tb" => 'MirrorH',
    "lr_tb$;tb_lr" => 'MirrorTL_BR',
    "tb_lr$;lr_tb" => 'MirrorTL_BR',
    "lr_tb$;tb_rl" => 'RotateR',
    "tb_rl$;lr_tb" => 'RotateL',
    "rl_tb$;tb_lr" => 'RotateL',
    "tb_lr$;rl_tb" => 'RotateR',
    "rl_tb$;tb_rl" => 'MirrorTR_BL',
    "tb_rl$;rl_tb" => 'MirrorTR_BL',
    "tb_lr$;tb_rl" => 'MirrorV',
    "tb_rl$;tb_lr" => 'MirrorV',
);

my %body_direction = (
    'lr_tb' => 'ltr',
    'rl_tb' => 'rtl',
    'tb_lr' => 'ltr',
    'tb_rl' => 'rtl',
);

my %writing_mode = (
    'lr_tb' => 'horizontal-tb',
    'rl_tb' => 'horizontal-tb',
    'tb_lr' => 'vertical-lr',
    'tb_rl' => 'vertical-rl',
);

my %text_orientation = (
    "rl_tb$;tb_lr" => 'sideways-left',
    "rl_tb$;tb_rl" => 'sideways-left',
);

sub new {
    my $pkg  = shift;
    my $self = {@_};

    my ($src) = grep {/^((lr|rl)_tb|tb_(lr|rl)|ltr|rtl|vertical-(lr|rl))$/}
	keys %$self;
    if ($src) {
	$src = $dir_synonym{$src} || $src;
	my $dest = $self->{$src};
	if ($dest) {
	    $dest = $dir_synonym{$dest} || $dest;
	    $self->{'body_direction'}   = $body_direction{$dest};
	    $self->{'writing_mode'}     = $writing_mode{$dest};
	    $self->{'text_orientation'} = $text_orientation{$src, $dest};
	    $self->{'adaptor'}          = $adaptor{$src, $dest};
	}
    }
    croak 'available transformation not found' unless $self->{'adaptor'};

    # compat.
    if (defined $self->{'swap_left_right_in_url'}) {
	$self->{'flip_url'} = $self->{'swap_left_right_in_url'};
    }

    # apply default
    foreach my $o (keys %defaults) {
	$self->{$o} = $defaults{$o} unless defined $self->{$o};
    }

    bless $self => $pkg;
}

# Substituttion of CSS gradients which cannot be performed only by regexp
# because they can contain nested parentheses.

my $GRADIENT_RE = qr<$IDENT[\.-]gradient\s*\(>i;

sub substituteGradient {
    my $self           = shift;
    my $match_function = shift;
    my $input_string   = shift;

    pos($input_string) = 0;
    my $output = '';
    my ($other, $match, $paren_count);

    while ($input_string =~ m{\G(.*?)($GRADIENT_RE)}cg) {
	($other, $match) = ($1, $2);

	$paren_count = 1;
	while ($paren_count and $input_string =~ m{\G(\(|\)|[^()]+)}cg) {
	    if ($1 eq '(') {
		$paren_count++;
	    } elsif ($1 eq ')') {
		$paren_count--;
	    }
	    $match .= $1;
	}

	# pos() is at last closing parenthesis (or end of text).
	$output .= $other . &$match_function($match);
    }
    return $output . substr($input_string, pos($input_string));
}

# fixBodyDirectionLtrAndRtl ($line)
#
# Replaces ltr with rtl and vice versa ONLY in the body direction:
# 'body { direction:ltr }' => 'body { direction:rtl }'

sub fixBodyDirectionLtrAndRtl {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    return $line
	if $adaptor eq 'MirrorTL_BR' or
	    $adaptor eq 'MirrorTR_BL';

    $line =~ s{$BODY_DIRECTION_LTR_RE}{$1$2$3~TMP~}g;
    $line =~ s{$BODY_DIRECTION_RTL_RE}{$1$2$3ltr}g;
    $line =~ s{~TMP~}{rtl}g;

    return $line;
}

my $SINGLE_BORDER_RADIUS_RE =
    qr<((?:$IDENT)?)border-(?:(top|bottom)-(left|right)-radius|radius-(top|bottom)(left|right))(\s*:\s*)(?:$POSSIBLY_NEGATIVE_QUANTITY\s+)?(?:$POSSIBLY_NEGATIVE_QUANTITY)>i;
my $SINGLE_BORDER_RADIUS_TOKENIZER_RE =
    qr<((?:$IDENT)?border-(?:(top|bottom)-(left|right)-radius|radius-(top|bottom)(left|right))\s*:[^;}]+;?)>i;

my $BOX_DIRECTION_RE =
    qr<$LOOKBEHIND_NOT_LETTER(top|right|bottom|left)$LOOKAHEAD_NOT_CLOSING_PAREN$LOOKAHEAD_NOT_OPEN_BRACE>i;

my $BOX_DIRECTION_IN_URL_RE =
    qr<$LOOKBEHIND_NOT_LETTER(top|right|bottom|left)$LOOKAHEAD_FOR_CLOSING_PAREN>i;

my $LINE_RELATIVE_DIRECTION_RE =
    qr<((?:(?:$IDENT)?text-align(?:-last)?|float|clear|vertical-align)\s*:\s*[^;}]*;?)>;
my $DROPPED_DIRECTION_RE = qr<((?:ruby-position|ruby-align)\s*:\s*[^;}]*;?)>;

sub fixBoxDirectionPart {
    my $adaptor   = shift;
    my $direction = shift;

    if ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
	return {
	    'right' => 'left',
	    'left'  => 'right',
	    }->{$direction} ||
	    $direction;
    } elsif ($adaptor eq 'MirrorTL_BR') {
	return {
	    'top'    => 'left',
	    'right'  => 'bottom',
	    'bottom' => 'right',
	    'left'   => 'top',
	    }->{$direction} ||
	    $direction;
    } elsif ($adaptor eq 'MirrorTR_BL') {
	return {
	    'top'    => 'right',
	    'right'  => 'top',
	    'bottom' => 'left',
	    'left'   => 'bottom',
	    }->{$direction} ||
	    $direction;
    } elsif ($adaptor eq 'RotateR') {
	return {
	    'top'    => 'right',
	    'right'  => 'bottom',
	    'bottom' => 'left',
	    'left'   => 'top',
	    }->{$direction} ||
	    $direction;
    } elsif ($adaptor eq 'RotateL') {
	return {
	    'top'    => 'left',
	    'right'  => 'top',
	    'bottom' => 'right',
	    'left'   => 'bottom',
	    }->{$direction} ||
	    $direction;
    } else {
	croak "This can't happen!";
    }
}

# fixSingleBorderRadius ($line)

sub fixSingleBorderRadiusName {
    my $adaptor = shift;
    my @m       = @_;

    if (defined $m[0]) {
	if ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
	    return 'border-' . fixBoxDirectionPart($adaptor, $m[0]) . '-' .
		fixBoxDirectionPart($adaptor, $m[1]) . '-radius';
	} else {
	    return 'border-' . fixBoxDirectionPart($adaptor, $m[1]) . '-' .
		fixBoxDirectionPart($adaptor, $m[0]) . '-radius';
	}
    } else {
	if ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
	    return 'border-radius-' . fixBoxDirectionPart($adaptor, $m[2]) .
		fixBoxDirectionPart($adaptor, $m[3]);
	} else {
	    return 'border-radius-' . fixBoxDirectionPart($adaptor, $m[3]) .
		fixBoxDirectionPart($adaptor, $m[2]);
	}
    }
}

sub fixSingleBorderRadius {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    $line =~ s{$SINGLE_BORDER_RADIUS_RE}{
	if (defined $7) {
	    if ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
		$1 . fixSingleBorderRadiusName($adaptor, $2, $3, $4, $5) .
		    "$6$7 $8";
	    } else {
		$1 . fixSingleBorderRadiusName($adaptor, $2, $3, $4, $5) .
		    "$6$8 $7";
	    }
	} else {
	    $1 . fixSingleBorderRadiusName($adaptor, $2, $3, $4, $5) .
		"$6$8";
	}
    }eg;

    return $line;
}

# fixBoxDirection ($line)
#
# Replaces left with right and vice versa in line, e,g,:
# 'padding-left: 2px; margin-right: 1px;' =>
# 'padding-right: 2px; margin-left: 1px;'
#
# Note: Old name is fixLeftAndRight().

sub fixBoxDirection {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    $line =~ s{$BOX_DIRECTION_RE}{
	fixBoxDirectionPart($adaptor, $1)
    }eg;

    return $line;
}

# fixBoxDirectionInUrl ($line)
#
# Replaces left with right and vice versa within background URLs, e.g.:
# 'background:url(right.png)' => 'background:url(left.png)'
#
# Note: Old name is fixLeftAndRightInUrl().

sub fixBoxDirectionInUrl {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    $line =~ s{$BOX_DIRECTION_IN_URL_RE}{
	fixBoxDirectionPart($adaptor, $1)
    }eg;

    return $line;
}

# fixLtrAndRtlInUrl ($line)
#
# Replaces ltr with rtl and vice versa within background URLs, e.g.:
# 'background:url(rtl.png)' => 'background:url(ltr.png)'

sub fixLtrAndRtlInUrl {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    return $line
	if $adaptor eq 'MirrorTL_BR' or
	    $adaptor eq 'MirrorTR_BL';

    $line =~ s{$LTR_IN_URL_RE}{~TMP~}g;
    $line =~ s{$RTL_IN_URL_RE}{ltr}g;
    $line =~ s{~TMP~}{rtl}g;

    return $line;
}

my $CURSOR_DIRECTION_RE =
    qr<$LOOKBEHIND_NOT_LETTER(nesw|nwse|[ns][we]|[nswe])-resize>;

sub fixCursorDirection {
    my $adaptor   = shift;
    my $direction = shift;

    if ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
	$direction =~ tr/ew/we/;
    } elsif ($adaptor eq 'MirrorTL_BR') {
	$direction =~ tr/nesw/wsen/;
    } elsif ($adaptor eq 'MirrorTR_BL') {
	$direction =~ tr/nesw/enws/;
    } elsif ($adaptor eq 'RotateR') {
	$direction =~ tr/nesw/eswn/;
    } elsif ($adaptor eq 'RotateL') {
	$direction =~ tr/nesw/wnes/;
    } else {
	croak "This can't happen!";
    }
    $direction =~ s/^([ew])([ns])/$2$1/;
    $direction =~ s/([ew])([ns])$/$2$1/;
    $direction =~ s/^(s[ew])(n[ew])$/$2$1/;

    $direction;
}

# fixCursorProperties ($line)
#
# Changes directional CSS cursor properties:
# 'cursor: ne-resize' => 'cursor: nw-resize'

sub fixCursorProperties {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    $line =~ s{$CURSOR_DIRECTION_RE}{
	fixCursorDirection($adaptor, $1) . '-resize';
    }eg;

    return $line;
}

# fixBorderRadius ($line)
#
# Changes border-radius and its browser-specific variants, e.g.:
# 'border-radius: 1px 2px 3px 4px / 5px 6px 7px' =>
# 'border-radius: 2px 1px 4px 3px / 6px 5px 6px 7px'

sub fixBorderRadius {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    $line =~ s{$BORDER_RADIUS_RE}{
	$self->reorderBorderRadius($&, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    }eg;

    return $line;
}

# fixFourPartNotation ($line)
#
# Fixes the second and fourth positions in four-part CSS notation, e.g.:
# 'padding: 1px 2px 3px 4px' => 'padding: 1px 4px 3px 2px'

sub fixFourPartNotation {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    if ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
	$line =~ s{$FOUR_NOTATION_QUANTITY_RE}{$1 $4 $3 $2}g;
	$line =~ s{$FOUR_NOTATION_COLOR_RE}{$1$2 $5 $4 $3}g;
    } elsif ($adaptor eq 'MirrorTL_BR') {
	$line =~ s{$FOUR_NOTATION_QUANTITY_RE}{$4 $3 $2 $1}g;
	$line =~ s{$FOUR_NOTATION_COLOR_RE}{$1$5 $4 $3 $2}g;
    } elsif ($adaptor eq 'MirrorTR_BL') {
	$line =~ s{$FOUR_NOTATION_QUANTITY_RE}{$2 $1 $4 $3}g;
	$line =~ s{$FOUR_NOTATION_COLOR_RE}{$1$3 $2 $5 $4}g;
    } elsif ($adaptor eq 'RotateR') {
	$line =~ s{$FOUR_NOTATION_QUANTITY_RE}{$4 $1 $2 $3}g;
	$line =~ s{$FOUR_NOTATION_COLOR_RE}{$1$5 $2 $3 $4}g;
    } elsif ($adaptor eq 'RotateL') {
	$line =~ s{$FOUR_NOTATION_QUANTITY_RE}{$2 $3 $4 $1}g;
	$line =~ s{$FOUR_NOTATION_COLOR_RE}{$1$3 $4 $5 $2}g;
    } else {
	croak "This can't happen!";
    }

    return $line;
}

# fixBackgroundPosition ($line)
#
# METHOD.  Changes horizontal background values in line.
#
# If value is not replaceable, croak it (by default) or carp it (if
# 'ignore_bad_bgp' option is set).

sub fixBackgroundPosition {
    my $self = shift;
    my $line = shift;

    my $adaptor = $self->{'adaptor'} || return $line;
    return $line
	if $adaptor eq 'MirrorTL_BR' or
	    $adaptor eq 'MirrorTR_BL';

    $line =~ s{$BG_HORIZONTAL_PERCENTAGE_RE}{
	calculateNewBackgroundPosition($&, $1, $2, $3, $4, $5)
    }eg;
    $line =~ s{$BG_HORIZONTAL_PERCENTAGE_X_RE}{
	calculateNewBackgroundPositionX($&, $1, $2)
    }eg;
    $line =~ s{$BG_HORIZONTAL_LENGTH_RE}{
	$self->calculateNewBackgroundLengthPosition($&, $1, $2, $3, $4, $5)
    }eg;
    $line =~ s{$BG_HORIZONTAL_LENGTH_X_RE}{
	$self->calculateNewBackgroundLengthPositionX($&, $1, $2)
    }eg;

    return $line;
}

# Takes a list of zero to four border radius parts and returns a string of
# them reordered for bidi mirroring.

sub reorderBorderRadiusPart {
    my $adaptor = shift;
    my @part    = @_;

    # Remove any piece which may be 'None'
    @part = grep { defined $_ and length $_ } @part;

    return join ' ', @part
	unless $adaptor;

    if (scalar @part == 0) {
	return '';
    }
    if (scalar @part == 1) {
	$part[1] = $part[0];
    }
    if (scalar @part == 2) {
	$part[2] = $part[0];
    }
    if (scalar @part == 3) {
	$part[3] = $part[1];
    }

    if ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
	@part = @part[1, 0, 3, 2];
    } elsif ($adaptor eq 'MirrorTL_BR') {
	@part = @part[0, 3, 2, 1];
    } elsif ($adaptor eq 'MirrorTR_BL') {
	@part = @part[2, 1, 0, 3];
    } elsif ($adaptor eq 'RotateR') {
	@part = @part[3, 0, 1, 2];
    } elsif ($adaptor eq 'RotateL') {
	@part = @part[1, 2, 3, 0];
    } else {
	croak "This can't happen!";
    }

    if ($part[3] eq $part[1]) {
	pop @part;
	if ($part[2] eq $part[0]) {
	    pop @part;
	    if ($part[1] eq $part[0]) {
		pop @part;
	    }
	}
    }
    return join ' ', @part;
}

# Receives a match object for a border-radius element and reorders it pieces.
sub reorderBorderRadius {
    my $self    = shift;
    my @m       = @_;
    my $adaptor = $self->{'adaptor'};

    my $first_group  = reorderBorderRadiusPart($adaptor, @m[3 .. 6]);
    my $second_group = reorderBorderRadiusPart($adaptor, @m[7 .. $#m]);
    if ($second_group eq '') {
	return sprintf '%sborder-radius%s%s', $_[1], $_[2], $first_group;
    } elsif ($adaptor eq 'MirrorH' or $adaptor eq 'MirrorV') {
	return sprintf '%sborder-radius%s%s / %s', $_[1], $_[2],
	    $first_group, $second_group;
    } else {
	return sprintf '%sborder-radius%s%s / %s', $_[1], $_[2],
	    $second_group, $first_group;
    }
}

# calculateNewBackgroundPosition ($&, $1, $2, $3, $4, $5)
#
# Changes horizontal background-position percentages, e.g.:
# 'background-position: 75% 50%' => 'background-position: 25% 50%'

sub calculateNewBackgroundPosition {
    my @m = @_;
    my $new_x;
    my $position_string;

    # The flipped value is the offset from 100%
    $new_x = 100 - int($m[4]);

    # Since m.group(1) may very well be None type and we need a string..
    if ($m[1]) {
	$position_string = $m[1];
    } else {
	$position_string = '';
    }

    return sprintf 'background%s%s%s%s%%%s',
	$position_string, $m[2], $m[3], $new_x, $m[5];
}

# calculateNewBackgroundPositionX ($&, $1, $2)
#
# Fixes percent based background-position-x, e.g.:
# 'background-position-x: 75%' => 'background-position-x: 25%'

sub calculateNewBackgroundPositionX {
    my @m = @_;
    my $new_x;

    # The flipped value is the offset from 100%
    $new_x = 100 - int($m[2]);

    return sprintf 'background-position-x%s%s%%', $m[1], $new_x;
}

my $BACKGROUND_POSITION_ERROR_MESSAGE =
    "Unmirrorable horizonal value \"%s\": %s\n";

sub warnForBackgroundPosition {
    my $self        = shift;
    my $bad_length  = shift;
    my $whole_value = shift;

    my $msg = sprintf $BACKGROUND_POSITION_ERROR_MESSAGE, $bad_length,
	$whole_value;
    if ($self->{'ignore_bad_bgp'}) {
	$@ = $msg;
	carp $msg;
    } else {
	croak $msg;
    }
}

# calculateNewBackgroundLengthPosition ($&, $1, $2, $3, $4, $5)
#
# Changes horizontal background-position lengths, e.g.:
# 'background-position: 0px 10px' => 'background-position: 100% 10px'
#
# If value is not replaceable, croak it (by default) or carp it (if
# 'ignore_bad_bgp' option is set).

sub calculateNewBackgroundLengthPosition {
    my $self = shift;
    my @m    = @_;
    my $position_string;

    # croak if the length is not zero-valued
    unless ($m[4] =~ m{^$ZERO_LENGTH}) {
	$self->warnForBackgroundPosition($m[4], $m[0]);
	return $m[0];
    }

    if (defined $m[1] and length $m[1]) {
	$position_string = $m[1];
    } else {
	$position_string = '';
    }

    return sprintf 'background%s%s%s100%%%s',
	$position_string, $m[2], $m[3], $m[5];
}

# calculateNewBackgroundLengthPositionX ($&, $1, $2)
#
# Fixes background-position-x lengths, e.g.:
# 'background-position-x: 0' => 'background-position-x: 100%'
#
# If value is not replaceable, croak it (by default) or carp it (if
# 'ignore_bad_bgp' option is set).

sub calculateNewBackgroundLengthPositionX {
    my $self = shift;
    my @m    = @_;

    # croak if the length is not zero-valued
    unless ($m[2] =~ m{^$ZERO_LENGTH}) {
	$self->warnForBackgroundPosition($m[2], $m[0]);
	return $m[0];
    }

    return sprintf 'background-position-x%s100%%', $m[1];
}

=head2 Methods

=over 4

=item body_direction

Get direction property or dir attribute of body element thought to be
appropriate.
Returns C<'ltr'>, C<'rtl'> or undef (unknown).

=back

=cut

sub body_direction {
    shift->{'body_direction'} || undef;
}

=over 4

=item text_orientation

Get text-orientation property of texts assumed.
Returns C<'sideways-left'> or undef (upright or sideways-right is assumed).

=back

=cut

sub text_orientation {
    shift->{'text_orientation'} || undef;
}

=over 4

=item transform ( $lines, [ options... ] )

Runs the fixing functions against CSS source.

$lines is a string.
Following options are available.

=over 4

=item swap_ltr_rtl_in_url =E<gt> 0|1

Overrides this flag if param is set.

=item flip_url =E<gt> 0|1

Overrides this flag if param is set.

=item flip_cursor =E<gt> 0|1

Overrides this flag if param is set.

=back

Returns same lines directions are changed.

=back

=cut

sub transform {
    my $self = shift;
    my $line = shift;
    my %opts = @_;

    return undef unless defined $line;
    return $line unless $self->{'adaptor'};

    # Possibly override flags with params.
    my $swap_ltr_rtl_in_url = $opts{'swap_ltr_rtl_in_url'};
    my $flip_url            = $opts{'flip_url'};
    my $flip_cursor         = $opts{'flip_cursor'};

    # compat.
    if (defined $opts{'swap_left_right_in_url'}) {
	$flip_url = $opts{'swap_left_right_in_url'};
    }

    unless (defined $swap_ltr_rtl_in_url) {
	$swap_ltr_rtl_in_url = $self->{'swap_ltr_rtl_in_url'};
    }
    unless (defined $flip_url) {
	$flip_url = $self->{'flip_url'};
    }
    unless (defined $flip_cursor) {
	$flip_cursor = $self->{'flip_cursor'};
    }

    my @originals = ();

    # Tokenize tokens tokenizer can be confused.
    $line =~ s{(~[A-Z_\d]+~)}{
	push @originals, $1;
	'~X_' . (scalar @originals) . '~'
    }eg;

    # Tokenize any single line rules with the /* noflip */ annotation.
    $line =~ s{$NOFLIP_SINGLE_RE}{
	push @originals, $1;
	'~NOFLIP_SINGLE_' . (scalar @originals) . '~'
    }eg;

    # Tokenize any class rules with the /* noflip */ annotation.
    $line =~ s{$NOFLIP_CLASS_RE}{
	push @originals, $1;
	'~NOFLIP_CLASS_' . (scalar @originals) . '~'
    }eg;

    # Tokenize the comments so we can preserve them through the changes.
    $line =~ s{$COMMENT_RE}{
	push @originals, $1;
	'~C_' . (scalar @originals) . '~'
    }eg;

    # Tokenize gradients since we don't want to mirror the values inside
    $line = $self->substituteGradient(
	sub {
	    push @originals, shift;
	    '~GRADIENT_' . (scalar @originals) . '~';
	},
	$line
    );

    # Tokenize line-relative properties if any, because
    # direction of line-relative properties should not be modified
    # except true ltr-rtl swapping.
    unless ($self->{'adaptor'} eq 'MirrorH') {
	$line =~ s{$LINE_RELATIVE_DIRECTION_RE}{
	    push @originals, $1;
	    '~LINE_RELATIVE_' . (scalar @originals) . '~'
	}eg;
    }

    # Tokenize properties including "right"/"left" proposed to be dropped
    $line =~ s{$DROPPED_DIRECTION_RE}{
	push @originals, $1;
	'~DROPPED_DIRECTION_' . (scalar @originals) . '~'
    }eg;

    # Here start the various direction fixes.

    $line = $self->fixBodyDirectionLtrAndRtl($line);

    if ($flip_url) {
	$line = $self->fixBoxDirectionInUrl($line);
    }

    if ($swap_ltr_rtl_in_url) {
	$line = $self->fixLtrAndRtlInUrl($line);
    }

    $line = $self->fixSingleBorderRadius($line);

    # Since BoxDirection conflicts with SingleBorderRadius, we tokenize
    # border-<corner>-radius properties here.
    $line =~ s{$SINGLE_BORDER_RADIUS_TOKENIZER_RE}{
	push @originals, $1;
	'~SINGLE_BORDER_RADIUS_' . (scalar @originals) . '~'
    }eg;
    $line = $self->fixBoxDirection($line);
    $line =~ s{~SINGLE_BORDER_RADIUS_(\d+)~}{$originals[$1 - 1]}eg;

    if ($flip_cursor) {
	$line = $self->fixCursorProperties($line);
    }

    $line = $self->fixBorderRadius($line);

    # Since FourPartNotation conflicts with BorderRadius, we tokenize
    # border-radius properties here.
    $line =~ s{$BORDER_RADIUS_TOKENIZER_RE}{
	push @originals, $1;
	'~BORDER_RADIUS_' . (scalar @originals) . '~'
    }eg;
    $line = $self->fixFourPartNotation($line);
    $line =~ s{~BORDER_RADIUS_(\d+)~}{$originals[$1 - 1]}eg;

    $line = $self->fixBackgroundPosition($line);

    # DeTokenize properties including "right"/"left" proposed to be dropped
    $line =~ s{~DROPPED_DIRECTION_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize line-relative properties, if any
    $line =~ s{~LINE_RELATIVE_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize gradients
    $line =~ s{~GRADIENT_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize the single line noflips.
    $line =~ s{~NOFLIP_SINGLE_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize the class-level noflips.
    $line =~ s{~NOFLIP_CLASS_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize the comments.
    $line =~ s{~C_(\d+)~}{$originals[$1 - 1]}eg;

    # Detokenize tokens tokenizer can be confused.
    $line =~ s{~X_(\d+)~}{$originals[$1 - 1]}eg;

    return $line;
}

=over 4

=item writing_mode

Get writing-mode property of texts thought to be appropriate.
Returns C<'horizontal-tb'>, C<'vertical-lr'>, C<'vertical-rl'> or undef
(unknown).

=back

=cut

sub writing_mode {
    shift->{'writing_mode'} || undef;
}

=head1 VERSION

Consult C<$VERSION> variable.

=head1 SEE ALSO

L<CSS::Janus>

Extended CSSJanus supporting vertical-rl writing-mode:
L<http://www.epubcafe.jp/download>

=head1 AUTHOR

Hatuka*nezumi - IKEDA Soji <hatuka(at)nezumi.nu>.

=head1 COPYRIGHT

Copyright (C) 2013 Hatuka*nezumi - IKEDA Soji.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

1;
