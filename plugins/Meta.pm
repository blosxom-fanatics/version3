# Blosxom 3.0+1i Plugin: Meta
# Use meta-tags in entries as variables
# 2004-04-30
# Rael Dornfest <rael@raelity.org>

package Blosxom::Plugin::Meta;

# --- Configurable variables -----

# What prefix should I expect prepended to each meta tag?
my $meta_prefix = 'meta-';

# --------------------------------

sub run {
	my $self = shift;

  my($body, $in_header) = ('', 1);

  foreach ( split /\n/, $self->{state}->{current_entry}->{body} ) {
    /^\s*$/ and $in_header = 0 and next;
    if ( $in_header ) {
      my($key, $value) = m!^$meta_prefix(.+?):\s*(.+)$!;
			$key =~ /^\w+$/ and $self->{state}->{current_entry}->{Plugin}->{Meta}->{$key} = $value and next;
    }
    $body .= $_ . "\n";
  }
  $self->{state}->{current_entry}->{body} = $body;

  return 1;
}

1;


__END__

=head1 NAME

Blosxom 3.0 Plugin: Meta

=head1 SYNOPSIS

Populates a $self->{state}->{current_entry}->{Plugin}->{Meta} hash
with variables corresponding to meta tags found in the "header"
(anything before a blank line) of a weblog post, removing the meta
tags along the way.  These variables are available to plug-ins and
flavour templates as $Plugin::Meta::variablename.

=head1 VERSION

2004-04-30

Version number coincides with the date of plugin release.

=head1 AUTHOR

Rael Dornfest  <rael@raelity.org>, http://www.raelity.org/

=head1 SEE ALSO

Blosxom Home/Docs/Licensing: http://www.raelity.org/apps/blosxom/

Blosxom Plugin Docs: http://www.raelity.org/apps/blosxom/plugin.shtml

=head1 BUGS

Address bug reports and comments to the Blosxom mailing list 
[http://www.yahoogroups.com/group/blosxom].

=head1 LICENSE

Copyright 2004, Rael Dornfest 

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
