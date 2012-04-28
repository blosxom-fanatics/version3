# Blosxom 3.0 Plugin: Dump
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-07

package Blosxom::Plugin::Dump;

use strict;

# --- Configurable variables -----------

my $dumpfile_path = './dump.txt';

# --- Plug-in package variables --------

# --------------------------------------

use CGI qw(:standard);

sub check_and_dump {
	my $self = shift;

	if (param('debug') == 1) {
		$self->{state}->{filehandle} ||= new FileHandle;
		my $fh = $self->{state}->{filehandle};
		
		if ($fh->open("+> $dumpfile_path")) {
			use Data::Dumper;

			print $fh Dumper $self;
			$fh->close;
		}
	}
}

1;
