# Blosxom 3.0 Plugin: Listing
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::Listing;

use strict;

# --- Configurable variables -----------

# flavourname for listing entries
my $flavour = "list";

# --- Plug-in package variables --------

# --------------------------------------

sub change_flavour {
	my $self = shift;

	if (
		$self->{request}->{flavour} eq 'html' and
		defined $self->{request}->{yr} and
		defined $self->{request}->{mo_num} and
		!defined$self->{request}->{da}
	) {
		$self->{request}->{flavour} = $flavour;
		$self->{settings}->{max_entries} = 10000;
		my @entries_sorted = reverse @{$self->{entries_sorted}};
		$self->{entries_sorted} = \@entries_sorted;
	}
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: Listing

=head1 SYNOPSIS

Change the flavour if visitors access yearly or monthly archives page.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::Listing::change_flavour after
   Blosxom::sort_entries before Blosxom::run_entries in handlers.flow.

2. Create flavours for listing.

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
