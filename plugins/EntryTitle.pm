# Blosxom 3.0 Plugin: EntryTitle
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::EntryTitle;

use strict;

# --- Configurable variables -----------

# separator string between $blog_title and $entry_title
my $title_sep = " - ";

# --- Plug-in package variables --------

# --------------------------------------

sub generate_title {
	my $self = shift;

	if (
		$self->{request}->{path_info} =~ m!(.*?)/?([\w-]+)\.([\w-]+)$! and
		$2 ne 'index'
	) {
		my $id = ${$self->{response}->{entries}}[0];
		my $title = $title_sep . $self->{entries}->{$id}->{title};

		# only works with Categories
		if ($self->{entries}->{$id}->{Plugin}->{Categories}->{category}) {
			my $category = $self->{entries}->{$id}->{Plugin}->{Categories}->{category};
			$title = $title_sep . $category . $title;
		}

		$self->{state}->{current_entry}->{Plugin}->{EntryTitle}->{title} = $title;
	}
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: Categories

=head1 SYNOPSIS

Provide a entry title separately for putting into title element if
visitors access individual entry page.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::EntryTitle::generate_title after
   Blosxom::run_entries in handlers.flow.

2. Put $Plugin::EntryTitle::title in head.flavour or foot.flavour.

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
