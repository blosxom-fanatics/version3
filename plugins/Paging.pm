# Blosxom 3.0 Plugin: Paging
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::Paging;

use strict;

# --- Configurable variables -----------

# --- Plug-in package variables --------

# --------------------------------------

use CGI qw(:standard);

sub initialize {
	my $self = shift;

	my $page = param('page');

	if (
		defined $self->{request}->{yr} or
		$self->{request}->{path_info} !~ m!(.*?)/?([\w-]+)\.([\w-]+)$! and
		$2 eq 'index'
	) {
		return 0;
	}

	my @entries;

	foreach (@{$self->{entries_sorted}}) {
		push(@entries, $_) if /^$self->{settings}->{find_entries_dir}$self->{request}->{path_info}/;
	}

	my $number_of_entries = $#entries + 1;
	my $number_of_pages = $number_of_entries / $self->{settings}->{max_entries};
  $number_of_pages = int($number_of_pages + 1)
  	unless $number_of_pages == int($number_of_pages);
	my $current_page_number = (param('page') =~ /^\d+$/ ? param('page') : 1);
	$current_page_number = 1 if $current_page_number > $number_of_pages;
	$self->{state}->{Plugin}->{Paging}->{number_of_pages} = $number_of_pages;
	$self->{state}->{Plugin}->{Paging}->{current_page_number} = $current_page_number;
}

sub filter_entry_by_page {
	my $self = shift;

	++$self->{state}->{Plugin}->{Paging}->{current_entry_number} <= ($self->{state}->{Plugin}->{Paging}->{current_page_number} - 1) * $self->{settings}->{max_entries} and $self->{state}->{stop}->{handlers}->{entry}++, return 0;

	1;
}

sub render {
	my $self = shift;

	unless (
		$self->{request}->{path_info} =~ m!(.*?)/?([\w-]+)\.([\w-]+)$! and
		$2 ne 'index'
	) {
		my $number_of_pages = $self->{state}->{Plugin}->{Paging}->{number_of_pages};
		my $current_page_number = $self->{state}->{Plugin}->{Paging}->{current_page_number};

		# prev navigation
		if ($current_page_number > 1) {
			my $prev_page_number = $current_page_number - 1;
			my $prev_url = ($prev_page_number == 1 ? $self->{settings}->{url} . $self->{request}->{path_info} : $self->{settings}->{url} . $self->{request}->{path_info} . "?page=" . $prev_page_number);

			$self->{state}->{current_entry}->{Plugin}->{Paging}->{prev}->{url} = $prev_url;

			$self->{state}->{current_entry}->{Plugin}->{Paging}->{prev}->{link} = qq!<link rel="prev" href="$prev_url" />!;

			my $template = $self->get_template('paging_prev');
			$self->{state}->{current_entry}->{Plugin}->{Paging}->{prev}->{rendered} = $self->interpolate($template);
		}

		# next navigation
		if ($current_page_number < $number_of_pages) {
			my $next_page_number = $current_page_number + 1;
			my $next_url = $self->{settings}->{url} . $self->{request}->{path_info} . "?page=" . $next_page_number;

			$self->{state}->{current_entry}->{Plugin}->{Paging}->{next}->{url} = $next_url;

			$self->{state}->{current_entry}->{Plugin}->{Paging}->{next}->{link} = qq!<link rel="next" href="$next_url" />!;

			my $template = $self->get_template('paging_next');
			$self->{state}->{current_entry}->{Plugin}->{Paging}->{next}->{rendered} = $self->interpolate($template);
		}
	}
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: Paging

=head1 SYNOPSIS

Provide a paging navigation(s) (rendered by original flavour) and a link
element(s) for vistors access past entries more easyly.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::Paging::initialize just before
   Blosxom::run_entries in handlers.flow.

2. Put Blosxom::Plugin::Paging::filter_entry_by_page after
   Blosxom::filter_entry_by_date before Blosxom::shortcut_max_entries in
   handlers.entry.

3. Put Blosxom::Plugin::Paging::render after Blosxom::run_entries in
   handlers.flow.

4. Create paging_next.flavour and paging_prev.flavour.

5. Put $Plugin::Paging::prev::link, $Plugin::Paging::next::link,
   $Plugin::Paging::prev::rendered and $Plugin::Paging::next::rendered
   in head.flavour or foot.flavour.

=head1 EXAMPLE

Here is the sample paging_prev.flavour:

  <p>
  <a href="$Plugin::Paging::prev::url">
  Go to previous page
  </a>
  </p>

$Plugin::BackAndForth::prev::url is a url of previous entry, and
$Plugin::BackAndForth::prev::title is a title of previous entry.

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
