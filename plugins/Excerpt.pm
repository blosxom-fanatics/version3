# Blosxom 3.0 Plugin: Excerpt
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::Excerpt;

use strict;

# --- Configurable variables -----------

# --- Plug-in package variables --------

# --------------------------------------

sub generate_excerpt {
	my $self = shift;

	my $excerpt = $self->{state}->{current_entry}->{body};

	$excerpt =~ s!\x0D|\x0A!!g;
	$excerpt =~ s!^<p>(.*?)</p>.*$!$1!;
	$excerpt =~ s!<.*?>!!g;
	$excerpt =~ s![、。！？\!?.,]*$!...!;

	$self->{state}->{current_entry}->{Plugin}->{Excerpt}->{excerpt} = $excerpt;
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: Excerpt

=head1 SYNOPSIS

Provide a excerpt of the entries (suitable for description of items of
RSS) from first paragraph.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::Excerpt::generate_excerpt after
   Blosxom::read_entry_file in handlers.entry.

2. Put $Plugin::Excerpt::excerpt in entry.flavour.

=head1 VERSION

2004-05-08

Initial release

=head1 AUTHOR

Kyo Nagashima <kyo@hail2u.net>, http://hail2u.net/

=head1 SEE ALSO

Blosxom Home/Docs/Licensing:
http://www.blosxom.com/

Blosxom Plugin Docs:
http://www.blosxom.com/documentation/users/plugins.html

=head1 BUGS

Address bug reports and comments to the Blosxom mailing list:
http://www.yahoogroups.com/group/blosxom

=head1 LICENSE

Copyright 2004, Kyo Nagashima

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

=cut
