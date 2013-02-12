#-*- perl -*-
#-*- coding: us-ascii -*-

=encoding utf-8

=head1 NAME

CSS::Janus - Converts a left-to-right Cascading Style Sheet (CSS) into a right-to-left one

=head1 SYNOPSIS

  use CSS::Janus;
  
  $janus = CSS::Janus->new;
  @lines_rtl = @{$janus->ChangeLeftToRightToLeft(\@lines)};

=head1 DESCRIPTION

CSS::Janus replaces "left" oriented things in a Cascading Style Sheet (CSS)
file such as float, padding, margin with "right" oriented values, and vice
versa.

This module is a Perl port of CSSJanus by Lindsey Simon <elsigh@google.com>.

=cut

#use 5.004;

package CSS::Janus;

use strict;
use warnings;
use vars qw($VERSION $BASE_REVISION);
use Carp qw(carp croak);

$VERSION       = '0.01';
$BASE_REVISION = 'http://cssjanus.googlecode.com/svn/trunk@31';

=head2 Constructor

=over 4

=item new ( [ options... ] )

Creates new CSS::Janus object.
Following options are available.

=over 4

=item swap_left_right_in_url =E<gt> 0|1

Fixes "left"/"right" string within URLs.

=item swap_ltr_rtl_in_url =E<gt> 0|1

Fixes "ltr"/"rtl" string within URLs.

=item ignore_bad_bgp =E<gt> 0|1

Ignores unmirrorable background-position values.

=back

=back

=cut

sub new {
    my $pkg = shift;
    bless {@_} => $pkg;
}

## Private constants

my $NON_ASCII = '[\200-\377]';
my $UNICODE   = "(?:(?:\\\\[0-9a-f]{1,6})(?:\\r\\n|[ \\t\\r\\n\\f])?)";
my $ESCAPE    = "(?:$UNICODE|\\\\[^\\r\\n\\f0-9a-f])";
my $NMSTART   = "(?:[_a-z]|$NON_ASCII|$ESCAPE)";
my $URL_SPECIAL_CHARS = '[!#$%&*-~]';
my $UNIT = '(?:em|ex|px|cm|mm|in|pt|pc|deg|rad|grad|ms|s|hz|khz|%)';

my $NMCHAR    = "(?:[_a-z0-9-]|$NON_ASCII|$ESCAPE)";
my $IDENT     = "-?$NMSTART$NMCHAR*";
my $NAME      = "$NMCHAR+";
my $HASH      = "#$NAME";
my $NUM       = '(?:[0-9]*\.[0-9]+|[0-9]+)';
my $URL_CHARS = "(?:$URL_SPECIAL_CHARS|$NON_ASCII|$ESCAPE)*";
my $COMMENT   = '/\*[^*]*\*+([^/*][^*]*\*+)*/';
my $QUANTITY  = "$NUM(?:\\s*$UNIT|$IDENT)?";

#X# Generic token delimiter character.
#Xmy $TOKEN_DELIMITER = '~';

#X# This is a temporary match token we use when swapping strings.
#Xmy $TMP_TOKEN = "${TOKEN_DELIMITER}TMP${TOKEN_DELIMITER}";

#X# Token to be used for joining lines.
#Xmy $TOKEN_LINES = "${TOKEN_DELIMITER}J${TOKEN_DELIMITER}";

# Global constant text strings for CSS value matches.
#Xmy $LTR = 'ltr';
#Xmy $RTL = 'rtl';
#Xmy $LEFT = 'left';
#Xmy $RIGHT = 'right';

# This is a lookbehind match to ensure that we don't replace instances
# of our string token (left, rtl, etc...) if there's a letter in front of it.
# Specifically, this prevents replacements like 'background: url(bright.png)'.
my $LOOKBEHIND_NOT_LETTER = '(?<![a-zA-Z])';

# This is a lookahead match to make sure we don't replace left and right
# in actual classnames, so that we don't break the HTML/CSS dependencies.
# Read literally, it says ignore cases where the word left, for instance, is
# directly followed by valid classname characters and a curly brace.
# ex: .column-left {float: left} will become .column-left {float: right}
my $LOOKAHEAD_NOT_OPEN_BRACE = qr{(?!(?:$NMCHAR|~J~|\s|#|\:|\.|\,|\+|>)*?\{)};

# These two lookaheads are to test whether or not we are within a
# background: url(HERE) situation.
# Ref: http://www.w3.org/TR/CSS21/syndata.html#uri
my $VALID_AFTER_URI_CHARS       = qr{[\'\"]?\s*};
my $LOOKAHEAD_NOT_CLOSING_PAREN = qr<(?!$URL_CHARS?$VALID_AFTER_URI_CHARS\))>;
my $LOOKAHEAD_FOR_CLOSING_PAREN = qr<(?=$URL_CHARS?$VALID_AFTER_URI_CHARS\))>;

# Compile a regex to swap left and right values in 4 part notations.
# We need to match negatives and decimal numeric values.
# The case of border-radius is extra complex, so we handle it separately below.
# ex. 'margin: .25em -2px 3px 0' becomes 'margin: .25em 0 3px -2px'.

my $POSSIBLY_NEGATIVE_QUANTITY = "((?:-?$QUANTITY)|(?:inherit|auto))";
my $FOUR_NOTATION_QUANTITY_RE =
    qr<$POSSIBLY_NEGATIVE_QUANTITY\s+$POSSIBLY_NEGATIVE_QUANTITY\s+$POSSIBLY_NEGATIVE_QUANTITY\s+$POSSIBLY_NEGATIVE_QUANTITY>i;
my $COLOR = "($NAME|$HASH)";
my $FOUR_NOTATION_COLOR_RE =
    qr<(-color\s*:\s*)$COLOR\s$COLOR\s$COLOR\s($COLOR)>i;

# border-radius is very different from usual 4 part notation: ABCD should
# change to BADC (while it would be ADCB in normal 4 part notation), ABC
# should change to BABC, and AB should change to BA
my $BORDER_RADIUS_RE =
    qr<((?:$IDENT)?)border-radius(\s*:\s*)(?:$POSSIBLY_NEGATIVE_QUANTITY\s+)?(?:$POSSIBLY_NEGATIVE_QUANTITY\s+)?(?:$POSSIBLY_NEGATIVE_QUANTITY\s+)?(?:$POSSIBLY_NEGATIVE_QUANTITY)(?:\s*/\s*(?:$POSSIBLY_NEGATIVE_QUANTITY\s+)?(?:$POSSIBLY_NEGATIVE_QUANTITY\s+)?(?:$POSSIBLY_NEGATIVE_QUANTITY\s+)?(?:$POSSIBLY_NEGATIVE_QUANTITY))?>i;

# Compile the cursor resize regexes
my $CURSOR_EAST_RE = qr<$LOOKBEHIND_NOT_LETTER([ns]?)e-resize>;
my $CURSOR_WEST_RE = qr<$LOOKBEHIND_NOT_LETTER([ns]?)w-resize>;

# Matches the condition where we need to replace the horizontal component
# of a background-position value when expressed in horizontal percentage.
# Had to make two regexes because in the case of position-x there is only
# one quantity, and otherwise we don't want to match and change cases with only
# one quantity.
my $BG_HORIZONTAL_PERCENTAGE_RE =
    qr<background(-position)?(\s*:\s*)([^%]*?)($NUM)%(\s*(?:$POSSIBLY_NEGATIVE_QUANTITY|top|center|bottom))>;

my $BG_HORIZONTAL_PERCENTAGE_X_RE = qr<background-position-x(\s*:\s*)($NUM)%>;

# Non-percentage units used for CSS lengths
my $LENGTH_UNIT = "(?:em|ex|px|cm|mm|in|pt|pc)";

# To make sure the lone 0 is not just starting a number (like "02") or a percentage like ("0 %")
my $LOOKAHEAD_END_OF_ZERO = '(?![0-9]|\s*%)';

# A length with a unit specified. Matches "0" too, as it's a length, not a percentage.
my $LENGTH = qr<(?:-?$NUM(?:\s*$LENGTH_UNIT)|0+$LOOKAHEAD_END_OF_ZERO)>;

# Zero length. Used in the replacement functions.
my $ZERO_LENGTH = qr<(?:-?0+(?:\s*$LENGTH_UNIT)|0+$LOOKAHEAD_END_OF_ZERO)$>;

# Matches background, background-position, and background-position-x
# properties when using a CSS length for its horizontal positioning.
my $BG_HORIZONTAL_LENGTH_RE =
    qr<background(-position)?(\s*:\s*)((?:.+?\s+)??)($LENGTH)((?:\s+)(?:$POSSIBLY_NEGATIVE_QUANTITY|top|center|bottom))>;

my $BG_HORIZONTAL_LENGTH_X_RE = qr<background-position-x(\s*:\s*)($LENGTH)>;

# Matches the opening of a body selector.
#Xmy $BODY_SELECTOR = qr<body\s*\{\s*>;

# Matches anything up until the closing of a selector.
my $CHARS_WITHIN_SELECTOR = '[^\}]*?';

# Matches the direction property in a selector.
#Xmy $DIRECTION_RE = qr<direction\s*:\s*>:

# These allow us to swap "ltr" with "rtl" and vice versa ONLY within the
# body selector and on the same line.
my $BODY_DIRECTION_LTR_RE =
    qr<(body\s*{\s*)($CHARS_WITHIN_SELECTOR)(direction\s*:\s*)(ltr)>i;
my $BODY_DIRECTION_RTL_RE =
    qr<(body\s*{\s*)($CHARS_WITHIN_SELECTOR)(direction\s*:\s*)(rtl)>i;

# Allows us to swap "direction:ltr" with "direction:rtl" and
# vice versa anywhere in a line.
#Xmy $DIRECTION_LTR_RE = qr<direction\s*:\s*(ltr)>;
#Xmy $DIRECTION_RTL_RE = qr<direction\s*:\s*(rtl)>;

# We want to be able to switch left with right and vice versa anywhere
# we encounter left/right strings, EXCEPT inside the background:url(). The next
# two regexes are for that purpose. We have alternate IN_URL versions of the
# regexes compiled in case the user passes the flag that they do
# actually want to have left and right swapped inside of background:urls.
my $LEFT_RE =
    qr<$LOOKBEHIND_NOT_LETTER((?:top|bottom)?)(left)$LOOKAHEAD_NOT_CLOSING_PAREN$LOOKAHEAD_NOT_OPEN_BRACE>i;
my $RIGHT_RE =
    qr<$LOOKBEHIND_NOT_LETTER((?:top|bottom)?)(right)$LOOKAHEAD_NOT_CLOSING_PAREN$LOOKAHEAD_NOT_OPEN_BRACE>i;
my $LEFT_IN_URL_RE =
    qr<$LOOKBEHIND_NOT_LETTER(left)$LOOKAHEAD_FOR_CLOSING_PAREN>i;
my $RIGHT_IN_URL_RE =
    qr<$LOOKBEHIND_NOT_LETTER(right)$LOOKAHEAD_FOR_CLOSING_PAREN>i;
my $LTR_IN_URL_RE =
    qr<$LOOKBEHIND_NOT_LETTER(ltr)$LOOKAHEAD_FOR_CLOSING_PAREN>i;
my $RTL_IN_URL_RE =
    qr<$LOOKBEHIND_NOT_LETTER(rtl)$LOOKAHEAD_FOR_CLOSING_PAREN>i;

my $COMMENT_RE = qr<($COMMENT)>i;

#Xmy $NOFLIP_TOKEN = r'\@noflip'
# The NOFLIP_TOKEN inside of a comment. For now, this requires that comments
# be in the input, which means users of a css compiler would have to run
# this script first if they want this functionality.
#Xmy $NOFLIP_ANNOTATION = r'/\*%s%s%s\*/' % (\s*, NOFLIP_TOKEN, \s*)

# After a NOFLIP_ANNOTATION, and within a class selector, we want to be able
# to set aside a single rule not to be flipped. We can do this by matching
# our NOFLIP annotation and then using a lookahead to make sure there is not
# an opening brace before the match.
my $NOFLIP_SINGLE_RE =
    qr<(/\*\s*\@noflip\s*\*/$LOOKAHEAD_NOT_OPEN_BRACE[^;}]+;?)>i;

# After a NOFLIP_ANNOTATION, we want to grab anything up until the next } which
# means the entire following class block. This will prevent all of its
# declarations from being flipped.
my $NOFLIP_CLASS_RE = qr<(/\*\s*\@noflip\s*\*/$CHARS_WITHIN_SELECTOR})>i;

# border-radis properties and their values
my $BORDER_RADIUS_TOKENIZER_RE = qr<((?:$IDENT)?border-radius\s*:[^;}]+;?)>i;

# CSS gradients can't be expressed in normal regular expressions, since they
# can contain nested parentheses. So we emulate a re.sub-like function here.

my $GRADIENT_RE = qr<$IDENT[\.-]gradient\s*\(>i;

sub GradientMatcher_sub {

    #my $self = shift;
    my $match_function = shift;
    my $input_string   = shift;

    my @output = ();
    if ($input_string =~ m{$GRADIENT_RE}) {
	my @start = @-;
	my @end   = @+;
	while (@start) {
	    my $paren_count = 1;
	    my $index       = $end[0];
	    while ($paren_count > 0) {
		if ($index and substr($input_string, $index, 1) eq '(') {
		    $paren_count++;
		} elsif ($index and substr($input_string, $index, 1) eq ')') {
		    $paren_count--;
		}
		$index++;
	    }

# Here, index would point to the character after the matching closing parenthesis
	    my $replacement = &$match_function(
		substr($input_string, $start[0], $index - $start[0]));

	    push @output, substr($input_string, 0, $start[0]) . $replacement;
	    $input_string = substr($input_string, $index);
	    last unless $input_string =~ m{$GRADIENT_RE};
	    @start = @-;
	    @end   = @+;
	}
    }
    return join('', @output) . $input_string;
}

# FixBodyDirectionLtrAndRtl ($line)
#
# Replaces ltr with rtl and vice versa ONLY in the body direction.
#
# Args:
#   line: A string to replace instances of ltr with rtl.
# Returns:
#   line with direction: ltr and direction: rtl swapped only in body selector.
#   line = FixBodyDirectionLtrAndRtl('body { direction:ltr }')
#   line will now be 'body { direction:rtl }'.

sub FixBodyDirectionLtrAndRtl {
    my $line = shift;

    $line =~ s{$BODY_DIRECTION_LTR_RE}{$1$2$3~TMP~}g;
    $line =~ s{$BODY_DIRECTION_RTL_RE}{$1$2$3ltr}g;
    $line =~ s{~TMP~}{rtl}g;

    #  logging.debug('FixBodyDirectionLtrAndRtl returns: %s' % line)
    return $line;
}

# FixLeftAndRight ($line)
#
# Replaces left with right and vice versa in line.
#
# Args:
#   line: A string in which to perform the replacement.
#
# Returns:
#   line with left and right swapped. For example:
#   line = FixLeftAndRight('padding-left: 2px; margin-right: 1px;')
#   line will now be 'padding-right: 2px; margin-left: 1px;'.

sub FixLeftAndRight {
    my $line = shift;

    $line =~ s{$LEFT_RE}{$1~TMP~}g;
    $line =~ s{$RIGHT_RE}{$1left}g;
    $line =~ s{~TMP~}{right}g;

    #  logging.debug('FixLeftAndRight returns: %s' % line)
    return $line;
}

# FixLeftAndRightInUrl
#
# Replaces left with right and vice versa ONLY within background urls.
#
# Args:
#   line: A string in which to replace left with right and vice versa.
#
# Returns:
#   line with left and right swapped in the url string. For example:
#   line = FixLeftAndRightInUrl('background:url(right.png)')
#   line will now be 'background:url(left.png)'.

sub FixLeftAndRightInUrl {
    my $line = shift;

    $line =~ s{$LEFT_IN_URL_RE}{~TMP~}g;
    $line =~ s{$RIGHT_IN_URL_RE}{left}g;
    $line =~ s{~TMP~}{right}g;

    #  logging.debug('FixLeftAndRightInUrl returns: %s' % line)
    return $line;
}

# FixLtrAndRtlInUrl
#
# Replaces ltr with rtl and vice versa ONLY within background urls.
#
# Args:
#   line: A string in which to replace ltr with rtl and vice versa.
#
# Returns:
#   line with left and right swapped. For example:
#   line = FixLtrAndRtlInUrl('background:url(rtl.png)')
#   line will now be 'background:url(ltr.png)'.

sub FixLtrAndRtlInUrl {
    my $line = shift;

    $line =~ s{$LTR_IN_URL_RE}{~TMP~}g;
    $line =~ s{$RTL_IN_URL_RE}{ltr}g;
    $line =~ s{~TMP~}{rtl}g;

    #  logging.debug('FixLtrAndRtlInUrl returns: %s' % line)
    return $line;
}

# FixCursorProperties
#
# Fixes directional CSS cursor properties.
#
# Args:
#   line: A string to fix CSS cursor properties in.
#
# Returns:
#   line reformatted with the cursor properties substituted. For example:
#   line = FixCursorProperties('cursor: ne-resize')
#   line will now be 'cursor: nw-resize'.

sub FixCursorProperties {
    my $line = shift;

    $line =~ s{$CURSOR_EAST_RE}{$1~TMP~}g;
    $line =~ s{$CURSOR_WEST_RE}{$1e-resize}g;
    $line =~ s{~TMP~}{w-resize}g;

    #  logging.debug('FixCursorProperties returns: %s' % line)
    return $line;
}

# FixBorderRadius
#
# Fixes border-radius and its browser-specific variants.
#
# Args:
#   line: A string to fix border-radius in.
#
# Returns:
#   line reformatted with the border-radius values rearranged. For example:
#   line = FixBorderRadius('border-radius: 1px 2px 3px 4px / 5px 6px 7px')
#   line will now be 'border-radius: 2px 1px 4px 3px / 6px 5px 6px 7px'.

sub FixBorderRadius {
    my $line = shift;

    $line =~ s{$BORDER_RADIUS_RE}
    {ReorderBorderRadius($&, $1, $2, $3, $4, $5, $6, $7, $8)}eg;

    #  logging.debug('FixBorderRadius returns: %s' % line)
    return $line;
}

# FixFourPartNotation
#
# Fixes the second and fourth positions in 4 part CSS notation.
#
# Args:
#   line: A string to fix 4 part CSS notation in.
#
# Returns:
#   line reformatted with the 4 part notations swapped. For example:
#   line = FixFourPartNotation('padding: 1px 2px 3px 4px')
#   line will now be 'padding: 1px 4px 3px 2px'.

sub FixFourPartNotation {
    my $line = shift;

    $line =~ s{$FOUR_NOTATION_QUANTITY_RE}{$1 $4 $3 $2}g;
    $line =~ s{$FOUR_NOTATION_COLOR_RE}{$1$2 $5 $4 $3}g;

    #  logging.debug('FixFourPartNotation returns: %s' % line)
    return $line;
}

# FixBackgroundPosition
#
# Fixes horizontal background values in line.
#
# Args:
#   line: A string to fix horizontal background position values in.
#
# Returns:
#   line reformatted with the horizontal background values replaced, if possible.
#   Otherwise, an exception would be raised.

sub FixBackgroundPosition {
    my $self = shift;
    my $line = shift;

    $line =~ s{$BG_HORIZONTAL_PERCENTAGE_RE}
  {CalculateNewBackgroundPosition($&, $1, $2, $3, $4, $5)}eg;
    $line =~ s{$BG_HORIZONTAL_PERCENTAGE_X_RE}
  {CalculateNewBackgroundPositionX($&, $1, $2)}eg;
    $line =~ s{$BG_HORIZONTAL_LENGTH_RE}
  {$self->CalculateNewBackgroundLengthPosition($&, $1, $2, $3, $4, $5)}eg;
    $line =~ s{$BG_HORIZONTAL_LENGTH_X_RE}
  {$self->CalculateNewBackgroundLengthPositionX($&, $1, $2)}eg;

    #  logging.debug('FixBackgroundPosition returns: %s' % line)
    return $line;
}

# Takes a list of zero to four border radius parts and returns a string of them
# reordered for bidi mirroring.

sub ReorderBorderRadiusPart {
    my @part = @_;

    # Remove any piece which may be 'None'
    @part = grep { defined $_ and length $_ } @part;

    if (scalar @part == 4) {
	return "$part[1] $part[0] $part[3] $part[2]";
    } elsif (scalar @part == 3) {
	return "$part[1] $part[0] $part[1] $part[2]";
    } elsif (scalar @part == 2) {
	return "$part[1] $part[0]";
    } elsif (scalar @part == 1) {
	return $part[0];
    } elsif (scalar @part == 0) {
	return '';
    } else {
	croak "This can't happen!";
    }
}

# Receives a match object for a border-radius element and reorders it
# pieces.
sub ReorderBorderRadius {
    my @m = @_;

    my $first_group  = ReorderBorderRadiusPart(@m[3 .. 6]);
    my $second_group = ReorderBorderRadiusPart(@m[7 .. $#_]);
    if ($second_group eq '') {
	return sprintf '%sborder-radius%s%s', $_[1], $_[2], $first_group;
    } else {
	return sprintf '%sborder-radius%s%s / %s', $_[1], $_[2],
	    $first_group, $second_group;
    }
}

# CalculateNewBackgroundPosition
#
# Fixes horizontal background-position percentages.
#
# This function should be used as an argument to re.sub since it needs to
# perform replacement specific calculations.
#
# Args:
#   m: A match object.
#
# Returns:
#   A string with the horizontal background position percentage fixed.
#   BG_HORIZONTAL_PERCENTAGE_RE.sub(FixBackgroundPosition,
#                                   'background-position: 75% 50%')
#   will return 'background-position: 25% 50%'.

sub CalculateNewBackgroundPosition {
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

# CalculateNewBackgroundPositionX
#
# Fixes percent based background-position-x.
#
# This function should be used as an argument to re.sub since it needs to
# perform replacement specific calculations.
#
# Args:
#   m: A match object.
#
# Returns:
#   A string with the background-position-x percentage fixed.
#   BG_HORIZONTAL_PERCENTAGE_X_RE.sub(CalculateNewBackgroundPosition,
#                                     'background-position-x: 75%')
#   will return 'background-position-x: 25%'.

sub CalculateNewBackgroundPositionX {
    my @m = @_;
    my $new_x;

    # The flipped value is the offset from 100%
    $new_x = 100 - int($m[2]);

    return sprintf 'background-position-x%s%s%%', $m[1], $new_x;
}

my $BACKGROUND_POSITION_ERROR_MESSAGE =
    'Unmirrorable horizonal value %s: %s\n';

{

    # An exception created for background-position horizontal values set to
    # non-zero lengths which makes them unmirrorable.
    package BackgroundPositionError;
    use overload '""' => \&as_string;

    sub new {
	my $pkg         = shift;
	my $bad_length  = shift;
	my $whole_value = shift;

	bless {
	    'bad_length'  => $bad_length,
	    'whole_value' => $whole_value
	} => $pkg;
    }

    sub as_string {
	my $self = shift;
	return sprintf $BACKGROUND_POSITION_ERROR_MESSAGE,
	    $self->{'bad_length'}, $self->{'whole_value'};
    }
}

sub WarnForBackgroundPosition {
    my $self        = shift;
    my $bad_length  = shift;
    my $whole_value = shift;

    if ($self->{'ignore_bad_bgp'}) {
	carp $BACKGROUND_POSITION_ERROR_MESSAGE, $bad_length, $whole_value;
    } else {
	croak BackgroundPositionError->new($bad_length, $whole_value);
    }
}

# CalculateNewBackgroundLengthPosition
#
#   Fixes horizontal background-position lengths.
#
#   This function should be used as an argument to re.sub since it needs to
#   perform replacement specific calculations.
#
#   Args:
#     m: A match object.
#
#   Returns:
#     A string with the horizontal background position set to 100%, if zero.
#     Otherwise, an exception will be raised.
#     BG_HORIZONTAL_LENGTH_RE.sub(CalculateNewBackgroundLengthPosition,
#                                 'background-position: 0px 10px')
#     will return 'background-position: 100% 10px'.

sub CalculateNewBackgroundLengthPosition {
    my $self = shift;
    my @m    = @_;
    my $position_string;

    # raise an exception if the length is not zero-valued
    unless ($m[4] =~ m{^$ZERO_LENGTH}) {
	$self->WarnForBackgroundPosition($m[4], $m[0]);
	return $m[0];
    }

    # Since m.group(1) may very well be None type and we need a string..
    if (defined $m[1] and length $m[1]) {
	$position_string = $m[1];
    } else {
	$position_string = '';
    }

    return sprintf 'background%s%s%s100%%%s',
	$position_string, $m[2], $m[3], $m[5];
}

# CalculateNewBackgroundLengthPositionX
#
# Fixes background-position-x lengths.
#
# This function should be used as an argument to re.sub since it needs to
# perform replacement specific calculations.
#
# Args:
#   m: A match object.
#
# Returns:
#   A string with the background-position-x set to 100%, if zero.
#   Otherwiser, an exception will be raised.
#   BG_HORIZONTAL_LENGTH_X_RE.sub(CalculateNewBackgroundLengthPositionX,
#                                 'background-position-x: 0')
#   will return 'background-position-x: 100%'.

sub CalculateNewBackgroundLengthPositionX {
    my $self = shift;
    my @m    = @_;

    # raise an exception if the length is not zero-valued
    unless ($m[2] =~ m{^$ZERO_LENGTH}) {
	$self->WarnForBackgroundPosition($m[2], $m[0]);
	return $m[0];
    }

    return sprintf 'background-position-x%s100%%', $m[1];
}

=head2 Method

=over 4

=item ChangeLeftToRightToLeft ( $lines, [ options... ] )

Turns lines into a stream and runs the fixing functions against it.

$lines is a reference to array of lines.
Following options are available.

=over 4

=item swap_ltr_rtl_in_url =E<gt> 0|1

Overrides this flag if param is set.

=item swap_left_right_in_url =E<gt> 0|1

Overrides this flag if param is set.

=back

Returns
the reference to array of same lines, but with left and right fixes.

=back

=cut

sub ChangeLeftToRightToLeft {
    my $self                   = shift;
    my $lines                  = shift;
    my $swap_ltr_rtl_in_url    = shift;
    my $swap_left_right_in_url = shift;

    #  # Possibly override flags with params.
    #  logging.debug('ChangeLeftToRightToLeft swap_ltr_rtl_in_url=%s, '
    #                'swap_left_right_in_url=%s' % (swap_ltr_rtl_in_url,
    #                                               swap_left_right_in_url))
    unless (defined $swap_ltr_rtl_in_url) {
	$swap_ltr_rtl_in_url = $self->{'swap_ltr_rtl_in_url'};
    }
    unless (defined $swap_left_right_in_url) {
	$swap_left_right_in_url = $self->{'swap_left_right_in_url'};
    }

    # Turns the array of lines into a single line stream.
    #  logging.debug('LINES COUNT: %s' % len(lines))
    my $line = join '~J~', @$lines;
    my @originals = ();

    # Tokenize any single line rules with the /* noflip */ annotation.
    $line =~ s{$NOFLIP_SINGLE_RE}
  { push @originals, $1;
    '~NOFLIP_SINGLE_' . (scalar @originals) . '~'
  }eg;

    # Tokenize any class rules with the /* noflip */ annotation.
    $line =~ s{$NOFLIP_CLASS_RE}
  { push @originals, $1;
    '~NOFLIP_CLASS_' . (scalar @originals) . '~'
  }eg;

    # Tokenize the comments so we can preserve them through the changes.
    $line =~ s{$COMMENT_RE}
  { push @originals, $1;
    '~C_' . (scalar @originals) . '~'
  }eg;

    # Tokenize gradients since we don't want to mirror the values inside
    $line = GradientMatcher_sub(
	sub {
	    push @originals, shift;
	    '~GRADIENT_' . (scalar @originals) . '~';
	},
	$line
    );

    # Here starteth the various left/right orientation fixes.
    $line = FixBodyDirectionLtrAndRtl($line);

    if ($swap_left_right_in_url) {
	$line = FixLeftAndRightInUrl($line);
    }

    if ($swap_ltr_rtl_in_url) {
	$line = FixLtrAndRtlInUrl($line);
    }

    $line = FixLeftAndRight($line);
    $line = FixCursorProperties($line);

    $line = FixBorderRadius($line);

# Since FourPartNotation conflicts with BorderRadius, we tokenize border-radius properties here.
    $line =~ s{$BORDER_RADIUS_TOKENIZER_RE}
  { push @originals, $1;
    '~BORDER_RADIUS_' . (scalar @originals) . '~'
  }eg;
    $line = FixFourPartNotation($line);
    $line =~ s{~BORDER_RADIUS_(\d+)~}{$originals[$1 - 1]}eg;

    $line = $self->FixBackgroundPosition($line);

    $line =~ s{~GRADIENT_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize the single line noflips.
    $line =~ s{~NOFLIP_SINGLE_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize the class-level noflips.
    $line =~ s{~NOFLIP_CLASS_(\d+)~}{$originals[$1 - 1]}eg;

    # DeTokenize the comments.
    $line =~ s{~C_(\d+)~}{$originals[$1 - 1]}eg;

    # Rejoin the lines back together.
    $lines = [split /~J~/, $line];

    return $lines;
}

=head1 VERSION

Consult C<$VERSION> variable.

=head1 SEE ALSO

CSSJanus L<http://cssjanus.commoner.com/>.

=head1 AUTHOR

Hatuka*nezumi - IKEDA Soji <hatuka(at)nezumi.nu>.

=head1 COPYRIGHT

Copyright (C) 2013 Hatuka*nezumi - IKEDA Soji.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

1;
