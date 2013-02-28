#-*- perl -*-
#-*- coding: us-ascii -*-

package CSS::Janus;

use strict;
#use warnings;
use CSS::Yamaantaka;

use vars qw(@ISA $VERSION);
$VERSION = '0.04_01';
@ISA     = qw(CSS::Yamaantaka);

sub new {
    my $pkg = shift;
    my $self = $pkg->SUPER::new(@_, 'adaptor' => 'MirrorH');
    bless $self => $pkg;
}

1;

__END__

=head1 NAME

CSS::Janus - Converts a left-to-right Cascading Style Sheet (CSS) into a right-to-left one

=head1 SYNOPSIS

  use CSS::Janus;
  
  $janus = CSS::Janus->new;
  $css_source_rtl = $janus->transform($css_source);

=head1 DESCRIPTION

As Janus has two faces, horizontal texts can run in two directions:
left to right and right to left.

CSS::Janus replaces "left" directed things in a Cascading Style Sheet (CSS)
file such as float, padding, margin with "right" directed values, and vice
versa.

This module is a Perl port of CSSJanus by Lindsey Simon <elsigh@google.com>.

=head2 Constructor

=over 4

=item new ( [ options... ] )

Creates new CSS::Janus object.
Following options are available.

=over 4

=item swap_left_right_in_url =E<gt> 0|1

Fixes "left"/"right" string within URLs.
Default is C<0>, won't fix.

=item swap_ltr_rtl_in_url =E<gt> 0|1

Fixes "ltr"/"rtl" string within URLs.
Default is C<0>, won't fix.

=item ignore_bad_bgp =E<gt> 0|1

Ignores unmirrorable background-position values.
Default is C<0>, won't ignore and will croak it.

=back

=back

=head2 Method

=over 4

=item transform ( $lines, [ options... ] )

Runs the fixing functions against CSS source.

$lines is a string.
Following options are available.

=over 4

=item swap_ltr_rtl_in_url =E<gt> 0|1

Overrides this flag if param is set.

=item swap_left_right_in_url =E<gt> 0|1

Overrides this flag if param is set.

=back

Returns same lines directions (left and right) are changed.

=back

=head1 VERSION

Consult C<$VERSION> variable.

=head1 SEE ALSO

CSSJanus L<http://cssjanus.commoner.com/>.

A PHP port of CSSJanus L<http://www.mediawiki.org/wiki/Manual:CSSJanus.php>.

=head1 AUTHOR

Hatuka*nezumi - IKEDA Soji <hatuka(at)nezumi.nu>.

=head1 COPYRIGHT

Copyright (C) 2013 Hatuka*nezumi - IKEDA Soji.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.


=cut

