#
# Copyright (c) 2004-2006 by the cairo perl team (see the file README)
#
# Licensed under the LGPL, see LICENSE file for more information.
#
# $Header$
#

package Cairo;

use strict;
use warnings;
use DynaLoader;

our @ISA = qw/DynaLoader/;

our $VERSION = '1.00';

sub dl_load_flags { $^O eq 'darwin' ? 0x00 : 0x01 }

Cairo->bootstrap ($VERSION);

# --------------------------------------------------------------------------- #

package Cairo;

1;

__END__

=head1 NAME

Cairo - Perl interface to the cairo library

=head1 SYNOPSIS

  use Cairo;

  my $surface = Cairo::ImageSurface->create ('argb32', 100, 100);
  my $cr = Cairo::Context->create ($surface);

  $cr->rectangle (10, 10, 40, 40);
  $cr->set_source_rgb (0, 0, 0);
  $cr->fill;

  $cr->rectangle (50, 50, 40, 40);
  $cr->set_source_rgb (1, 1, 1);
  $cr->fill;

  $cr->show_page;

  $surface->write_to_png ("output.png");

=head1 ABSTRACT

Cairo provides Perl bindings for the vector graphics library cairo.  It
supports multiple output targets, including PNG, PDF and SVG.  Cairo produces
identical output on all those targets.

=head1 API DOCUMENTATION

Note that this listing still lacks entries for I<Cairo::Surface>s and some
utility methods.

=head2 Drawing

=head3 Cairo::Context -- The cairo drawing context

I<Cairo::Context> is the main object used when drawing with Cairo. To draw with
Cairo, you create a I<Cairo::Context>, set the target surface, and drawing
options for the I<Cairo::Context>, create shapes with methods like
C<$cr->move_to> and C<$cr-E<gt>line_to>, and then draw shapes with
C<$cr-E<gt>stroke> or C<$cr-E<gt>fill>.

I<Cairo::Context>'s can be pushed to a stack via C<$cr-E<gt>save>. They may
then safely be changed, without loosing the current state. Use
C<$cr-E<gt>restore> to restore to the saved state.
=over

=head4 $cr = Cairo::Context->create ($surface)

=over

=item $surface: I<Cairo::Surface>

=back

=head4 $cr-E<gt>save

=head4 $cr->restore

=head4 $status = $cr->status

=head4 $surface = $cr->get_target

=head4 $cr->push_group

=head4 $cr->push_group_with_content ($content)

=over

=item $content: I<Cairo::Content>

=back

=head4 $pattern = $cr->pop_group

=head4 $cr->pop_group_to_source

=head4 $surface = $cr->get_group_target

=head4 $cr->set_source_rgb ($red, $green, $blue)

=over

=item $red: double

=item $green: double

=item $blue: double

=back

=head4 $cr->set_source_rgba ($red, $green, $blue, $alpha)

=over

=item $red: double

=item $green: double

=item $blue: double

=item $alpha: double

=back

=head4 $cr->set_source ($source)

=over

=item $source: I<Cairo::Pattern>

=back

=head4 $cr->set_source_surface ($surface, $x, $y)

=over

=item $surface: I<Cairo::Surface>

=item $x: double

=item $y: double

=back

=head4 $source = $cr->get_source

=head4 $cr->set_antialias ($antialias)

=over

=item $antialias: I<Cairo::Antialias>

=back

=head4 $antialias = $cr->get_antialias

=head4 $cr->set_dash ($offset, ...)

=over

=item $offset: double

=item ...: list of doubles

=back

=head4 $cr->set_fill_rule ($fill_rule)

=over

=item $fill_rule: I<Cairo::FillRule>

=back

=head4 $fill_rule = $cr->get_fill_rule

=head4 $cr->set_line_cap ($line_cap)

=over

=item $line_cap: I<Cairo::LineCap>

=back

=head4 $line_cap = $cr->get_line_cap

=head4 $cr->set_line_join ($line_join)

=over

=item $line_join: I<Cairo::LineJoin>

=back

=head4 $line_join = $cr->get_line_join

=head4 $cr->set_line_width ($width)

=over

=item $width: double

=back

=head4 $width = $cr->get_line_width

=head4 $cr->set_miter_limit ($ limit)

=over

=item $limit: double

=back

=head4 $limit = $cr->get_miter_limit

=head4 $cr->set_operator ($op)

=over

=item $op: I<Cairo::Operator>

=back

=head4 $op = $cr->get_operator

=head4 $cr->set_tolerance ($tolerance)

=over

=item $tolerance: double

=back

=head4 $tolerance = $cr->get_tolerance

=head4 $cr->clip

=head4 $cr->clip_preserve

=head4 $cr->reset_clip

=head4 $cr->fill

=head4 $cr->fill_preserve

=head4 ($x1, $y1, $x2, $y2) = $cr->fill_extents

=head4 $bool = $cr->in_fill ($x, $y)

=over

=item $x: double

=item $y: double

=back

=head4 $cr->mask ($pattern)

=over

=item $pattern: I<Cairo::Pattern>

=back

=head4 $cr->mask_surface ($surface, $surface_x, $surface_y)

=over

=item $surface: I<Cairo::Surface>

=item $surface_x: double

=item $surface_y: double

=back

=head4 $cr->paint

=head4 $cr->paint_with_alpha ($alpha)

=over

=item $alpha: double

=back

=head4 $cr->stroke

=head4 $cr->stroke_preserve

=head4 ($x1, $y1, $x2, $y2) = $cr->stroke_extents

=head4 $bool = $cr->in_stroke ($x, $y)

=over

=item $x: double

=item $y: double

=back

=head4 $cr->copy_page

=head4 $cr->show_page

=cut

# --------------------------------------------------------------------------- #

=head3 Paths -- Creating paths and manipulating path data

  $path = [
    { type => "move-to", points => [[1, 2]] },
    { type => "line-to", points => [[3, 4]] },
    { type => "curve-to", points => [[5, 6], [7, 8], [9, 10]] },
    ...
    { type => "close-path", points => [] },
  ];

I<Cairo::Path> is a data structure for holding a path. This data structure
serves as the return value for C<$cr-E<gt>copy_path_data> and
C<$cr-E<gt>copy_path_data_flat> as well the input value for
C<$cr-E<gt>append_path>.

I<Cairo::Path> is represented as an array reference that contains path
elements, represented by hash references with two keys: I<type> and I<points>.
The value for I<type> can be either of the following:

=over

=item C<move-to>

=item C<line-to>

=item C<curve-to>

=item C<close-path>

=back

The value for I<points> is an array reference which contains zero or more
points.  Points are represented as array references that contain two doubles:
I<x> and I<y>.  The necessary number of points depends on the I<type> of the
path element:

=over

=item C<move-to>: 1 point

=item C<line_to>: 1 point

=item C<curve-to>: 3 points

=item C<close-path>: 0 points

=back

The semantics and ordering of the coordinate values are consistent with
C<$cr-E<gt>move_to>, C<$cr-E<gt>line_to>, C<$cr-E<gt>curve_to>, and
C<$cr-E<gt>close_path>.

=head4 $path = $cr->copy_path

=head4 $path = $cr->copy_path_flat

=head4 $cr->append_path ($path)

=over

=item $path: I<Cairo::Path>

=back

=head4 ($x, $y) = $cr->get_current_point

=head4 $cr->new_path

=head4 $cr->new_sub_path

=head4 $cr->close_path

=head4 $cr->arc ($xc, $yc, $radius, $angle1, $angle2)

=over

=item $xc: double

=item $yc: double

=item $radius: double

=item $angle1: double

=item $angle2: double

=back

=head4 $cr->arc_negative ($xc, $yc, $radius, $angle1, $angle2)

=over

=item $xc: double

=item $yc: double

=item $radius: double

=item $angle1: double

=item $angle2: double

=back

=head4 $cr->curve_to ($x1, $y1, $x2, $y2, $x3, $y3)

=over

=item $x1: double

=item $y1: double

=item $x2: double

=item $y2: double

=item $x3: double

=item $y3: double

=back

=head4 $cr->line_to ($x, $y)

=over

=item $x: double

=item $y: double

=back

=head4 $cr->move_to ($x, $y)

=over

=item $x: double

=item $y: double

=back

=head4 $cr->rectangle ($x, $y, $width, $height)

=over

=item $x: double

=item $y: double

=item $width: double

=item $height: double

=back

=head4 $cr->glyph_path (...)

=over

=item ...: list of I<Cairo::Glyph>'s

=back

=head4 $cr->text_path ($utf8)

=over

=item $utf8: string in utf8 encoding

=back

=head4 $cr->rel_curve_to ($dx1, $dy1, $dx2, $dy2, $dx3, $dy3)

=over

=item $dx1: double

=item $dy1: double

=item $dx2: double

=item $dy2: double

=item $dx3: double

=item $dy3: double

=back

=head4 $cr->rel_line_to ($dx, $dy)

=over

=item $dx: double

=item $dy: double

=back

=head4 $cr->rel_move_to ($dx, $dy)

=over

=item $dx: double

=item $dy: double

=back

=cut

# --------------------------------------------------------------------------- #

=head3 Patterns -- Gradients and filtered sources

=head4 $status = $pattern->status

=head4 $type = $pattern->get_type

=head4 $pattern->set_matrix ($matrix)

=over

=item $matrix: I<Cairo::Matrix>

=back

=head4 $matrix = $pattern->get_matrix

=head4 $pattern = Cairo::SolidPattern->create_rgb ($red, $green, $blue)

=over

=item $red: double

=item $green: double

=item $blue: double

=back

=head4 $pattern = Cairo::SolidPattern->create_rgba ($red, $green, $blue, $alpha)

=over

=item $red: double

=item $green: double

=item $blue: double

=item $alpha: double

=back

=head4 $matrix = $pattern->get_matrix

=head4 $pattern = Cairo::SurfacePattern->create ($surface)

=over

=item $surface: I<Cairo::Surface>

=back

=head4 $pattern->set_extend ($extend)

=over

=item $extend: I<Cairo::Extend>

=back

=head4 $extend = $pattern->get_extend

=head4 $pattern->set_filter ($filter)

=over

=item $filter: I<Cairo::Filter>

=back

=head4 $filter = $pattern->get_filter

=head4 $pattern = Cairo::LinearGradient->create ($x0, $y0, $x1, $y1)

=over

=item $x0: double

=item $y0: double

=item $x1: double

=item $y1: double

=back

=head4 $pattern = Cairo::RadialGradient->create ($cx0, $cy0, $radius0, $cx1, $cy1, $radius1)

=over

=item $cx0: double

=item $cy0: double

=item $radius0: double

=item $cx1: double

=item $cy1: double

=item $radius1: double

=back

=head4 $pattern->add_color_stop_rgb (double offset, double red, double green, double blue)

=over

=item $offset: double

=item $red: double

=item $green: double

=item $blue: double

=back

=head4 $pattern->add_color_stop_rgba (double offset, double red, double green, double blue, double alpha)

=over

=item $offset: double

=item $red: double

=item $green: double

=item $blue: double

=item $alpha: double

=back

=cut

# --------------------------------------------------------------------------- #

=head3 Transformations -- Manipulating the current transformation matrix

=head4 $cr->translate ($tx, $ty)

=over

=item $tx: double

=item $ty: double

=back

=head4 $cr->scale ($sx, $sy)

=over

=item $sx: double

=item $sy: double

=back

=head4 $cr->rotate ($angle)

=over

=item $angle: double

=back

=head4 $cr->transform ($matrix)

=over

=item $matrix: I<Cairo::Matrix>

=back

=head4 $cr->set_matrix ($matrix)

=over

=item $matrix: I<Cairo::Matrix>

=back

=head4 $matrix = $cr->get_matrix

=head4 $cr->identity_matrix

=head4 ($x, $y) = $cr->user_to_device ($x, $y)

=over

=item $x: double

=item $y: double

=back

=head4 ($dx, $dy) = $cr->user_to_device_distance ($dx, $dy)

=over

=item $dx: double

=item $dy: double

=back

=head4 ($x, $y) = $cr->device_to_user ($x, $y)

=over

=item $x: double

=item $y: double

=back

=head4 ($dx, $dy) = $cr->device_to_user_distance ($dx, $dy)

=over

=item $dx: double

=item $dy: double

=back

=cut

# --------------------------------------------------------------------------- #

=head3 Text -- Rendering text and sets of glyphs

Glyphs are represented as anonymous hash references with three keys: I<index>,
I<x> and I<y>.  Example:

  my @glyphs = ({ index => 1, x => 2, y => 3 },
                { index => 2, x => 3, y => 4 },
                { index => 3, x => 4, y => 5 });

=head4 $cr->select_font_face ($family, $slant, $weight)

=over

=item $family: string

=item $slant: I<Cairo::FontSlant>

=item $weight: I<Cairo::FontWeight>

=back

=head4 $cr->set_font_size ($size)

=over

=item $size: double

=back

=head4 $cr->set_font_matrix ($matrix)

=over

=item $matrix: I<Cairo::Matrix>

=back

=head4 $matrix = $cr->get_font_matrix

=head4 $cr->set_font_options ($options)

=over

=item $options: I<Cairo::FontOptions>

=back

=head4 $options = $cr->get_font_options

=head4 $cr->set_scaled_font ($scaled_font)

=over

=item $scaled_font: I<Cairo::ScaledFont>

=back

=head4 $cr->show_text ($utf8)

=over

=item $utf8: string

=back

=head4 $cr->show_glyphs (...)

=over

=item ...: list of glyphs

=back

=head4 $face = $cr->get_font_face

=head4 $extents = $cr->font_extents

=head4 $cr->set_font_face ($font_face)

=over

=item $font_face: I<Cairo::FontFace>

=back

=head4 $cr->set_scaled_font ($scaled_font)

=over

=item $scaled_font: I<Cairo::ScaledFont>

=back

=head4 $extents = $cr->text_extents ($utf8)

=over

=item $utf8: string

=back

=head4 $extents = $cr->glyph_extents (...)

=over

=item ...: list of glyphs

=back

=cut

# --------------------------------------------------------------------------- #

=head2 Fonts

=head3 Cairo::FontFace -- Base class for fonts

=head4 $status = $font_face->status

=head4 $type = $font_face->get_type

=cut

# --------------------------------------------------------------------------- #

=head3 Scaled Fonts -- Caching metrics for a particular font size

=head4 $scaled_font = Cairo::ScaledFont->create ($font_face, $font_matrix, $ctm, $options)

=over

=item $font_face: I<Cairo::FontFace>

=item $font_matrix: I<Cairo::Matrix>

=item $ctm: I<Cairo::Matrix>

=item $options: I<Cairo::FontOptions>

=back

=head4 $status = $scaled_font->status

=head4 $extents = $scaled_font->extents

=head4 $extents = $scaled_font->text_extents ($utf8)

=over

=item $utf8: string

=back

=head4 $extents = $scaled_font->glyph_extents (...)

=over

=item ...: list of glyphs

=back

=head4 $font_face = $scaled_font->get_font_face

=head4 $options = $scaled_font->get_font_options

=head4 $font_matrix = $scaled_font->get_font_matrix

=head4 $ctm = $scaled_font->get_ctm

=head4 $type = $scaled_font->get_type

=cut

# --------------------------------------------------------------------------- #

=head3 Font Options -- How a font should be rendered

=head4 $font_options = Cairo::FontOptions->create

=head4 $status = $font_options->status

=head4 $font_options->merge ($other)

=over

=item $other: I<Cairo::FontOptions>

=back

=head4 $hash = $font_options->hash

=head4 $bools = $font_options->equal ($other)

=over

=item $other: I<Cairo::FontOptions>

=back

=head4 $font_options->set_antialias ($antialias)

=over

=item $antialias: I<Cairo::AntiAlias>

=back

=head4 $antialias = $font_options->get_antialias

=head4 $font_options->set_subpixel_order ($subpixel_order)

=over

=item $subpixel_order: I<Cairo::SubpixelOrder>

=back

=head4 $subpixel_order = $font_options->get_subpixel_order

=head4 $font_options->set_hint_style ($hint_style)

=over

=item $hint_style: I<Cairo::HintStyle>

=back

=head4 $hint_style = $font_options->get_hint_style

=head4 $font_options->set_hint_metrics ($hint_metrics)

=over

=item $hint_metrics: I<Cairo::HintMetrics>

=back

=head4 $hint_metrics = $font_options->get_hint_metrics

=cut

# --------------------------------------------------------------------------- #

=head2 Utilities

=head3 Version Information -- Run-time and compile-time version checks.

=head4 $version = Cairo->version

=head4 $string = Cairo->version_string

=head4 $version_code = Cairo->VERSION

=head4 $version_code = Cairo->VERSION_ENCODE ($major, $minor, $micro)

=over

=item $major: integer

=item $minor: integer

=item $micro: integer

=back

=cut

# --------------------------------------------------------------------------- #

=head1 SEE ALSO

=over

=item http://cairographics.org/documentation

Lists many available resources including tutorials and examples

=item http://cairographics.org/manual/

Contains the reference manual

=back

=head1 AUTHORS

=over

=item Ross McFarland E<lt>rwmcfa1 at neces dot comE<gt>

=item Torsten Schoenfeld E<lt>kaffeetisch at gmx dot deE<gt>

=back

=head1 COPYRIGHT

Copyright (C) 2004-2006 by the cairo perl team

=cut
