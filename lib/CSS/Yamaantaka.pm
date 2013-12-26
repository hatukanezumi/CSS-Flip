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

=cut

use 5.005;    # qr{} and $10 are required.

package CSS::Yamaantaka;

use strict;
#use warnings;
use Carp qw(carp croak);
use CSS::Yamaantaka::Consts;

# To be compatible with Perl 5.5.
use vars qw($VERSION $BASE_REVISION);
$VERSION       = '0.04_02';
$BASE_REVISION = 'http://cssjanus.googlecode.com/svn/trunk@31';

=head2 Constructor

=over 4

=item new ( SRC =E<gt> DEST, [ options... ] )

=item new ( C<'adaptor'> =E<gt> ADAPTOR, [ options... ] )

Creates new CSS::Yamaantaka object.

In first form, SRC and DEST are the original and resulting directions.
Available directions are
C<'lr_tb'>, C<'rl_tb'>, C<'tb_lr'> and C<'tb_rl'>.
Their synonyms are C<'ltr'>, C<'rtl'>, C<'vertical-lr'> and C<'vertical-rl'>,
respectively.

Following options are available.

=over 4

=item flip_bg =E<gt> 0|1

Fixes background positions properties.
Default is C<1>, will fix.

=item flip_cursor =E<gt> 0|1

Fixes positions "n"/"e"/"s"/"w" and so on within cursor properties.
Default is C<1>, will fix.

=item flip_url =E<gt> 0|1

Fixes "top"/"right"/"bottom"/"left" string within URLs.
Default is C<0>, won't fix.

=item ignore_bad_bgp =E<gt> 0|1

Ignores unmirrorable background-position values.
Default is C<1>, WILL ignore and won't croak it.

=item swap_ltr_rtl_in_url =E<gt> 0|1

Fixes "ltr"/"rtl" string within URLs, if needed.
Default is C<0>, won't fix.

=back

In second form, ADAPTOR is a name of package or an object.
package will be automatically loaded.
See L</Adaptors> about standard adaptors.

=back

=cut

my %defaults = (
    'flip_bg'             => 1,
    'flip_cursor'         => 1,
    'flip_url'            => 0,
    'ignore_bad_bgp'      => 1,
    'swap_ltr_rtl_in_url' => 0,
);

my %dir_synonym = (
    'ltr'         => 'lr_tb',
    'rtl'         => 'rl_tb',
    'vertical-lr' => 'tb_lr',
    'vertical-rl' => 'tb_rl',
);

my %adaptor = (
    "lr_tb$;rl_tb" => 'CSS::Yamaantaka::MirrorH',
    "rl_tb$;lr_tb" => 'CSS::Yamaantaka::MirrorH',
    "lr_tb$;tb_lr" => 'CSS::Yamaantaka::MirrorTL_BR',
    "tb_lr$;lr_tb" => 'CSS::Yamaantaka::MirrorTL_BR',
    "lr_tb$;tb_rl" => 'CSS::Yamaantaka::RotateR',
    "tb_rl$;lr_tb" => 'CSS::Yamaantaka::RotateL',
    "rl_tb$;tb_lr" => 'CSS::Yamaantaka::RotateL',
    "tb_lr$;rl_tb" => 'CSS::Yamaantaka::RotateR',
    "rl_tb$;tb_rl" => 'CSS::Yamaantaka::MirrorTR_BL',
    "tb_rl$;rl_tb" => 'CSS::Yamaantaka::MirrorTR_BL',
    "tb_lr$;tb_rl" => 'CSS::Yamaantaka::MirrorV',
    "tb_rl$;tb_lr" => 'CSS::Yamaantaka::MirrorV',
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
    my $dest;
    if ($src) {
	$dest = $self->{$src};
	if ($dest) {
	    $src  = $dir_synonym{$src}  || $src;
	    $dest = $dir_synonym{$dest} || $dest;
	    $self->{'body_direction'}   = $body_direction{$dest};
	    $self->{'writing_mode'}     = $writing_mode{$dest};
	    $self->{'text_orientation'} = $text_orientation{$src, $dest};
	    $self->{'adaptor'}          = $adaptor{$src, $dest};
	}
    }
    unless ($src and $dest and $src eq $dest) {
	croak 'available adaptor not found'
	    unless $self->{'adaptor'};
    }
    if ($self->{'adaptor'} and !ref $self->{'adaptor'}) {
	eval "use $self->{'adaptor'}";
	croak $@ if $@;
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
	unless $adaptor->willReverseGlobalDirection;

    $line =~ s{$BODY_DIRECTION_LTR_RE}{$1$2$3~TMP~}g;
    $line =~ s{$BODY_DIRECTION_RTL_RE}{$1$2$3ltr}g;
    $line =~ s{~TMP~}{rtl}g;

    return $line;
}

# fixSingleBorderRadius ($line)

sub fixSingleBorderRadiusName {
    my $adaptor = shift;
    my @m       = @_;

    if (defined $m[0]) {
	unless ($adaptor->willSwapHorizontalVertical) {
	    return 'border-' . $adaptor->fixBoxDirectionPart($m[0]) . '-' .
		$adaptor->fixBoxDirectionPart($m[1]) . '-radius';
	} else {
	    return 'border-' . $adaptor->fixBoxDirectionPart($m[1]) . '-' .
		$adaptor->fixBoxDirectionPart($m[0]) . '-radius';
	}
    } else {
	unless ($adaptor->willSwapHorizontalVertical) {
	    return 'border-radius-' . $adaptor->fixBoxDirectionPart($m[2]) .
		$adaptor->fixBoxDirectionPart($m[3]);
	} else {
	    return 'border-radius-' . $adaptor->fixBoxDirectionPart($m[3]) .
		$adaptor->fixBoxDirectionPart($m[2]);
	}
    }
}

sub fixSingleBorderRadius {
    my $self    = shift;
    my $line    = shift;
    my $adaptor = $self->{'adaptor'};

    $line =~ s{$SINGLE_BORDER_RADIUS_RE}{
	if (defined $7) {
	    unless ($adaptor->willSwapHorizontalVertical) {
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

    $line =~ s{$BOX_DIRECTIONS_RE}{
	if (defined $4) {
	    $adaptor->fixBoxDirectionPart($4);
	} elsif ($adaptor->willSwapHorizontalVertical) {
	    $adaptor->fixBoxDirectionPart($3) . $2 .
	    $adaptor->fixBoxDirectionPart($1);
	} else {
	    $adaptor->fixBoxDirectionPart($1) . $2 .
	    $adaptor->fixBoxDirectionPart($3);
	}
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
	$adaptor->fixBoxDirectionPart($1);
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
	unless $adaptor->willReverseGlobalDirection;

    $line =~ s{$LTR_IN_URL_RE}{~TMP~}g;
    $line =~ s{$RTL_IN_URL_RE}{ltr}g;
    $line =~ s{~TMP~}{rtl}g;

    return $line;
}

sub fixCursorDirection {
    my $adaptor   = shift;
    my $direction = shift;

    $direction = $adaptor->fixCursorPositions($direction);
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

    $line =~ s{$FOUR_NOTATION_QUANTITY_RE}{
	join(' ', $adaptor->reorderFourPartNotation($1, $2, $3, $4))
    }eg;
    $line =~ s{$FOUR_NOTATION_COLOR_RE}{
	$1 . join(' ', $adaptor->reorderFourPartNotation($2, $3, $4, $5))
    }eg;

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
#    return $line
#	unless $adaptor->willReverseGlobalDirection;

    $line =~ s{$BG_QUANTITY_RE}{
	$self->calculateNewBackgroundQuantityPosition(
	    $&, $1, $2, $3, $4, $5, $6
	)
    }eg;
    $line =~ s{$BG_HORIZONTAL_PERCENTAGE_X_RE}{
	$self->calculateNewBackgroundPositionX($&, $1, $2)
    }eg;
#    $line =~ s{$BG_HORIZONTAL_LENGTH_RE}{
#	$self->calculateNewBackgroundLengthPosition($&, $1, $2, $3, $4, $5)
#    }eg;
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

    @part = $adaptor->reorderBorderRadiusSubparts(@part);

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
    } elsif ($adaptor->willSwapHorizontalVertical) {
	return sprintf '%sborder-radius%s%s / %s', $_[1], $_[2],
	    $second_group, $first_group;
    } else {
	return sprintf '%sborder-radius%s%s / %s', $_[1], $_[2],
	    $first_group, $second_group;
    }
}

## calculateNewBackgroundPosition ($&, $1, $2, $3, $4, $5)
##
## Changes horizontal background-position percentages, e.g.:
## 'background-position: 75% 50%' => 'background-position: 25% 50%'
#
#sub calculateNewBackgroundPosition {
#    my $self = shift;
#    my @m = @_;
#    my $new_x;
#    my $position_string;
#
#    # The flipped value is the offset from 100%
#    $new_x = 100 - int($m[4]);
#
#    # Since m.group(1) may very well be None type and we need a string..
#    if ($m[1]) {
#	$position_string = $m[1];
#    } else {
#	$position_string = '';
#    }
#
#    return sprintf 'background%s%s%s%s%%%s',
#	$position_string, $m[2], $m[3], $new_x, $m[5];
#}

# calculateNewBackgroundPositionX ($&, $1, $2)
#
# Fixes percent based background-position-x, e.g.:
# 'background-position-x: 75%' => 'background-position-x: 25%'

sub calculateNewBackgroundPositionX {
    my $self = shift;
    my @m = @_;
    my $new_x;

    # The flipped value is the offset from 100%
    $new_x = 100 - int($m[2]);

    return sprintf 'background-position-x%s%s%%', $m[1], $new_x;
}

my $BACKGROUND_POSITION_ERROR_MESSAGE =
    "Unmirrorable position value \"%s\": %s\n";

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

## calculateNewBackgroundLengthPosition ($&, $1, $2, $3, $4, $5)
##
## Changes horizontal background-position lengths, e.g.:
## 'background-position: 0px 10px' => 'background-position: 100% 10px'
##
## If value is not replaceable, croak it (by default) or carp it (if
## 'ignore_bad_bgp' option is set).
#
#sub calculateNewBackgroundLengthPosition {
#    my $self = shift;
#    my @m    = @_;
#    my $position_string;
#
#    # croak if the length is not zero-valued
#    unless ($m[4] =~ m{^$ZERO_LENGTH}) {
#	$self->warnForBackgroundPosition($m[4], $m[0]);
#	return $m[0];
#    }
#
#    if (defined $m[1] and length $m[1]) {
#	$position_string = $m[1];
#    } else {
#	$position_string = '';
#    }
#
#    return sprintf 'background%s%s%s100%%%s',
#	$position_string, $m[2], $m[3], $m[5];
#}

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

# calculateNewBackgroundQuantityPosition ($&, $1, $2, $3, $4, $5, $6)
#
# Changes background-position percentages, e.g.:
# 'background-position: 75% 50%' => 'background-position: 25% 50%'

sub calculateNewBackgroundQuantityPosition {
    my $self = shift;
    my @m = @_;
    my $adaptor = $self->{'adaptor'};
    my $position_string;

    my @pos = ($m[6], undef, undef, $m[4]);
    # The flipped value is the offset from 100%
    if ($pos[3] =~ m{^($NUM)\%$}) {
	$pos[1] = (100 - int($1)) . '%';
    } elsif ($pos[3] =~ m{^$ZERO_LENGTH}) {
	$pos[1] = '100%';
    } elsif ($pos[3] =~ m{auto|inherit}) {
	$pos[1] = $pos[3];
    }
    if ($pos[0] =~ m{^($NUM)\%$}) {
	$pos[2] = (100 - int($1)) . '%';
    } elsif ($pos[0] =~ m{^$ZERO_LENGTH}) {
	$pos[2] = '100%';
    } elsif ($pos[0] =~ m{auto|inherit}) {
        $pos[2] = $pos[0];
    }

    @pos = $adaptor->reorderFourPartNotation(@pos);

    unless (defined $pos[0] and defined $pos[3]) {
	$self->warnForBackgroundPosition("$m[4]$m[5]$m[6]", $m[0]);
	return $m[0];
    }

    return sprintf 'background%s%s%s%s%s%s',
	$m[1], $m[2], $m[3], $pos[3], $m[5], $pos[0];
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

=item flip_bg =E<gt> 0|1

=item flip_cursor =E<gt> 0|1

=item flip_url =E<gt> 0|1

=item swap_ltr_rtl_in_url =E<gt> 0|1

Overrides these flags if params are set.

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
    my $flip_bg             = $opts{'flip_bg'};

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
    unless (defined $flip_bg) {
        $flip_bg = $self->{'flip_bg'};
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
    unless ($self->{'adaptor'}->willReverseLineRelativeDirection) {
	$line =~ s{$LINE_RELATIVE_DIRECTION_RE}{
	    push @originals, $1;
	    '~LINE_RELATIVE_' . (scalar @originals) . '~'
	}eg;
    }

    # Tokenize properties including "right"/"left" not to be changed.
    $line =~ s{$PROHIBITED_DIRECTION_RE}{
	push @originals, $1;
	'~PROHIBITED_DIRECTION_' . (scalar @originals) . '~'
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

    if ($flip_bg) {
	$line = $self->fixBackgroundPosition($line);
    }

    # DeTokenize properties including "right"/"left" not to be fixed
    $line =~ s{~PROHIBITED_DIRECTION_(\d+)~}{$originals[$1 - 1]}eg;

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

=head2 Adaptors

This module supports four directions of documents:

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

This module chooses adaptors by source & resulting directions:

  table 1. Choosing adaptors
  +-----------+-------------+-------------+-------------+--------------+
  | from \ to | lr-tb       : rl-tb       : tb-lr       : tb-rl        |
  +-----------+-------------+-------------+-------------+--------------+
  | lr-tb     |      -      : MirrorH     : MirrorTL_BR : RotateR      |
  | rl-tb     | MirrorH     :      -      : RotateL*    : MirrorTR_BL* |
  | tb-lr     | MirrorTL_BR : RotateR     :      -      : MirrorV      |
  | tb-rl     | RotateL     : MirrorTR_BL : MirrorV     :       -      |
  +-----------+-------------+-------------+-------------+--------------+
   * Assumed text-orientation: sideways-left.
  
   n.b.: Prefixing "CSS::Yamaantaka::" are omitted.

Each adaptor will or won't change following "directions" of CSS properties.

=over 4

=item line-relative box directions

"right" / "left" of text-align, float and clear.
"top" / "bottom" of vertical-align.

=item  physical box directions

"top" / "right" / "bottom" / "left".

=item global directions

Directions specified by body element, "ltr" / "rtl".

=item direction swapping

Horizontal and vertical orientation.

=back

  table 2. Feature of adaptors
  +-------------+-----------+-------------------------+---------+------+
  |             | line-rel. | box directions          : global  : h/v  |
  +-------------+-----------+-------------------------+---------+------+
  | MirrorH     | reverse h.: reverse horizontally    : reverse :   -  |
  | MirrorV     |     -     : reverse horizontally    : reverse :   -  |
  | RotateR     |     -     : rotate clockwise        : reverse : swap |
  | RotateL     |     -     : rotate counter-clockwise: reverse : swap |
  | MirrorTL_BR |     -     : reverse with tl-br axis :    -    : swap |
  | MirrorTR_BL |     -     : reverse with tr-bl axis :    -    : swap |
  +-------------+-----------+-------------------------+---------+------+

Any adaptors listed above won't fix line-relative text directions
("rtl" / "ltr").

=head1 VERSION

Consult C<$VERSION> variable.

=head1 SEE ALSO

L<CSS::Janus>

Extended CSSJanus supporting vertical-rl writing-mode:
L<http://www.epubcafe.jp/download>

L<cssflip(1)>

=head1 AUTHOR

Hatuka*nezumi - IKEDA Soji <hatuka(at)nezumi.nu>.

=head1 COPYRIGHT

Copyright (C) 2013 Hatuka*nezumi - IKEDA Soji.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

1;
