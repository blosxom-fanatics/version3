# Blosxom 3.0 Plugin: Feed
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-09

package Blosxom::Plugin::Feed;

use strict;

# --- Configurable variables -----------

my $url = 'http://hail2u.net';

# --- Plug-in package variables --------

# --------------------------------------

sub generate_content_encoded {
	my $self = shift;

	my $current_entry = $self->{state}->{current_entry};
	my $body = $current_entry->{body};

	$body =~ s!\x0D|\x0A!!g;
	$body =~ s!(href|src)="(/.*?)"!$1="$url$2"!g;

	$current_entry->{Plugin}->{Feed}->{content}->{encoded} = $body;
}

sub generate_excerpt {
	my $self = shift;

	my $current_entry = $self->{state}->{current_entry};
	my $excerpt = $current_entry->{body};

	$excerpt =~ s!\x0D|\x0A!!g;
	$excerpt =~ s!^<p>(.*?)</p>.*$!$1!;
	$excerpt =~ s!<.*?>!!g;
	$excerpt =~ s![、。！？\!?.,]*$!...!;

	$current_entry->{Plugin}->{Feed}->{excerpt} = $excerpt;
}

sub generate_channel_dc_date {
	my $self = shift;

	my $current_entry = $self->{state}->{current_entry};
	my $id = ${$self->{response}->{entries}}[0];
	my $latest_entry = $self->{entries}->{$id};
	my $yr     = $latest_entry->{yr};
	my $mo_num = $latest_entry->{mo_num};
	my $da     = $latest_entry->{da};
	my $hr24   = $latest_entry->{hr24};
	my $min    = $latest_entry->{min};
	my $sec    = $latest_entry->{sec};

	my $date = "$yr-$mo_num-$da$self->{settings}->{date_time_sep}$hr24:$min:$sec$self->{settings}->{tzd}";

	$current_entry->{Plugin}->{Feed}->{channel}->{dc}->{date} = $date;
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: Feed

=head1 SYNOPSIS

Provide a misc strings for playing with any feed format (RSS 0.91, RSS
1.0, RSS 2.0, Atom 0.3 or ESF 1.0), I hope -:p).

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::Feed::generate_channel_dc_date after
   Blosxom::run_entries in handlers.flow.

2. Put Blosxom::Plugin::Feed::generate_excerpt and
   Blosxom::Plugin::Feed::generate_content_encoded after
   Blosxom::run_entries in handlers.flow.

3. Put $Plugin::Feed::channel::dc::date in head.flavour or foot.flavour.

4. Put $Plugin::Feed::excerpt and $Plugin::Feed::content::encoded in
   entry.flavour.

=head1 VERSION

2004-05-09

Added generate_excerpt routine.

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
