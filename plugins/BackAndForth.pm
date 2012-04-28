# Blosxom 3.0 Plugin: BackAndForth
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::BackAndForth;

use strict;

# --- Configurable variables -----------

# --- Plug-in package variables --------

# --------------------------------------

sub render {
	my $self = shift;

	if (
		$self->{request}->{path_info} =~ m!(.*?)/?([\w-]+)\.([\w-]+)$! and
		$2 ne 'index'
	) {
		my $id = ${$self->{response}->{entries}}[0];
		my $i;

		foreach (@{$self->{entries_sorted}}) {
			last if $_ eq $id;
			$i++;
		}

		if ($i > 0) {
			my $next_entry = $self->{entries}->{${$self->{entries_sorted}}[$i - 1]};

			$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{next}->{url} = $self->{settings}->{url} . $next_entry->{path} . $next_entry->{fn} . '.' . $self->{request}->{flavour};
			$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{next}->{link} = qq!<link rel="next" href="$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{next}->{url}" />!;

			$self->{state}->{filehandle} ||= new FileHandle;
			my $fh = $self->{state}->{filehandle};
			
			if (
				-f $next_entry->{id} and
				$fh->open($next_entry->{id})
			) {
				chomp($self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{next}->{title} = <$fh>);
				$fh->close;
			}

			my $template = $self->get_template('back_and_forth_next');
			$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{next}->{rendered} = $self->interpolate($template);
		}

		if ($i < $#{$self->{entries_sorted}}) {
			my $prev_entry = $self->{entries}->{${$self->{entries_sorted}}[$i + 1]};

			$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{prev}->{url} = $self->{settings}->{url} . $prev_entry->{path} . $prev_entry->{fn} . '.' . $self->{request}->{flavour};
			$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{next}->{link} = qq!<link rel="prev" href="$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{prev}->{url}" />!;

			$self->{state}->{filehandle} ||= new FileHandle;
			my $fh = $self->{state}->{filehandle};
			
			if (
				-f $prev_entry->{id} and
				$fh->open($prev_entry->{id})
			) {
				chomp($self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{prev}->{title} = <$fh>);
				$fh->close;
			}

			my $template = $self->get_template('back_and_forth_prev');
			$self->{state}->{current_entry}->{Plugin}->{BackAndForth}->{prev}->{rendered} = $self->interpolate($template);
		}
	}
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: BackAndForth

=head1 SYNOPSIS

Provide an anchor tag(s) (rendered by original flavour) and a link
element(s) references previous and next entry if visitors access
individual entry page.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::BackAndForth::render after Blosxom::run_entries
   in handlers.flow.

2. Create back_and_forth_next.flavour and back_and_forth_prev.flavour.

3. Put $Plugin::BackAndForth::prev::link,
   $Plugin::BackAndForth::next::link,
   $Plugin::BackAndForth::prev::rendered and
   $Plugin::BackAndForth::next::rendered in head.flavour or
   foot.flavour.

=head1 EXAMPLES

Here is the sample back_and_forth_prev.flavour:

  <p>
  <a href="$Plugin::BackAndForth::prev::url">
  $Plugin::BackAndForth::prev::title
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
