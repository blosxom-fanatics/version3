# Blosxom 3.0+1i Package: EntryType
# Doesn't do much.
# 2004-04-27
# Rael Dornfest <rael@raelity.org>

package Blosxom::Plugin::EntryType;

sub run {
	my $self = shift;

	# Remember the flavour 
	my $flavour = $self->{request}->{flavour};

	# Set the flavour according to the entrytype
	$self->{request}->{flavour} = $self->{state}->{current_entry}->{Plugin}->{Meta}->{entrytype} || $flavour;

	# Call the built-in render_entry() routine
	Blosxom::render_entry($self);

	# Set the flavour back
	$self->{request}->{flavour} = $flavour;

	1;
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: EntryType

=head1 SYNOPSIS

Individual entries may be styled as particular flavours. Specify the
flavour of a particular post as a meta-entrytype: tag and the entry
will be rendered using that particular flavour's entry.flavourname
template component.

=head1 REQUIREMENTS

Requires the Meta plugin.

=head1 INSTALLATION AND CONFIGURATION

Drop into the Blosxom plugins directory and replace the call to the
built-in Blosxom::render_entry routine with 
Blosxom::Plugin::EntryType::run like so:

#Blosxom::render_entry
Blosxom::Plugin::EntryType::run

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
