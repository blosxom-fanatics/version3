# Blosxom 3.0+1i Package: Test
# Doesn't do much.
# 2004-04-27
# Rael Dornfest <rael@raelity.org>

package Blosxom::Plugin::Test;

# The default routine to be run is, well, run.

sub run {
	warn "running Blosxom::Plugin::Test";
	1;
}

# Any other arbitrary routines may be defined and called in the 
# appropriate place in flow or entry handling.

sub do_something {
	my $blosxom = shift;

	# do something with that blosxom
}

1;
