# Blosxom 3.0 Plugin: Archives
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::Archives;

use strict;

# --- Configurable variables -----------

# Customize your month names here if you want to.
my @monthnames = qw(January February March April May June July August September October November December);

# separator string between $blog_title and $archive_title
my $title_sep = " - ";

# separater string between each parts of date
my $date_sep = "/";

# --- Plug-in package variables --------

# --------------------------------------

sub generate_title {
	my $self = shift;

	if (defined $self->{request}->{yr}) {
		my $title = $title_sep . $self->{request}->{yr};

		if (defined $self->{request}->{mo_num}) {
			$title .= $date_sep . $self->{request}->{mo_num};

			if (defined $self->{request}->{da}) {
				$title .= $date_sep . $self->{request}->{da};
			}
		}

		$self->{state}->{current_entry}->{Plugin}->{Archives}->{title} = $title;
	}
}

sub render {
	my $self = shift;

	my %archive;

	foreach my $id (keys %{$self->{entries}}) {
		my @date  = localtime($self->{entries}->{$id}->{mtime});
		my $month = $date[4];
		my $year  = $date[5] + 1900;
		$archive{$year}{'count'}++;
		$archive{$year}{$month}{'count'}++;
	}

	my $archives = "<ul>\n";

	foreach my $year (sort {$b <=> $a} keys %archive) {
		$archives .= qq!<li>$year\n!;
		$archives .= "<ul>\n";
		delete $archive{$year}{'count'};

		foreach my $month (sort {$b <=> $a} keys %{$archive{$year}}) {
			my $mnum = sprintf("%02d", $month + 1);
			$archives .= qq!<li><a href="$self->{settings}->{url}/$year/$mnum/">$monthnames[$month]</a> ($archive{$year}{$month}{'count'})</li>\n!;
		}

		$archives .= "</ul>\n</li>\n";
	}

	$archives .= "</ul>";

	$self->{state}->{current_entry}->{Plugin}->{Archives}->{rendered} = $archives;
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: Archives

=head1 SYNOPSIS

Provide a unnumbered list of archives by html and provide a
year-month-date string separately for putting into title element if
visitors access archives page.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::Archives::generate_title and
   Blosxom::Plugin::Archives::render after Blosxom::run_entries in your
   handlers.flow.

2. $Plugin::Archives::title and $Plugin::Archives::rendered in any
   flavour.

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
