# Blosxom 3.0 Plugin: Similarity
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-07

package Blosxom::Plugin::Similarity;

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
		use URI::Escape qw(uri_escape);

		$self->{state}->{current_entry}->{Plugin}->{Similarity}->{url} = uri_escape("$self->{settings}->{url}$self->{state}->{current_entry}->{path}$self->{state}->{current_entry}->{fn}.$self->{settings}->{permalink_flavour}");

		my $template = $self->get_template('similarity');
		$self->{state}->{current_entry}->{Plugin}->{Similarity}->{rendered} = $self->interpolate($template);
	}
}

1;
