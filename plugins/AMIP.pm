# Blosxom 3.0 Plugin: AMIP
# Author(s): Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-07

package Blosxom::Plugin::AMIP;

use strict;

# --- Configurable variables -----------

my $data_filename = "$blosxom::plugin_state_dir/amip.dat";
my $associate_id  = "hail2unet-22";

# --- Plug-in package variables --------

my $stat     = "Error";
my $artist   = "null";
my $title    = "null";
my $track    = "null";
my $album    = "null";
my $year     = "null";
my $comment  = "null";
my $genre    = "null";
my $code = <<"_HTML_";
<p>Some error occured on Winamp, Apollo or AMIP plugin.</p>
_HTML_

# --------------------------------------

sub render {
	my $self = shift;

  return 0 if ($self->{request}->{flavour} ne 'html');

	if (open(AMIP, "$self->{settings}->{state_dir}/$data_filename")) {
		foreach (<AMIP>) {
			$stat    = &escape_special_characters($1) if (/^stat=(.*)$/);
			$artist  = &escape_special_characters($1) if (/^artist=(.*)$/);
			$title   = &escape_special_characters($1) if (/^title=(.*)$/);
			$track   = &escape_special_characters($1) if (/^track=(.*)$/);
			$album   = &escape_special_characters($1) if (/^album=(.*)$/);
			$year    = &escape_special_characters($1) if (/^year=(.*)$/);
			$comment = &escape_special_characters($1) if (/^comment=(.*)$/);
			$genre   = &escape_special_characters($1) if (/^genre=(.*)$/);
		}

		close AMIP;

		if ($comment =~ /^[A-Z0-9]+$/) {
			my $asin_url = "http://www.amazon.co.jp/exec/obidos/ASIN/$comment/$associate_id";
			my $img_url	= "/images/asin/$comment.jpg";
			$code = <<"_HTML_";
<p class="amip">$title</p>
<div class="amip"><a href="$asin_url"><img src="$img_url" alt="$artist - $album" /></a></div>
<p class="amip"><a href="$asin_url">$artist</a></p>
<p class="amip"><a href="$asin_url">$album</a></p>
_HTML_
		} else {
			use URI::Escape qw(uri_escape);

			my $artist_e = uri_escape($artist);
			my $album_e	= uri_escape($album);
			$code = <<"_HTML_";
<dl>
<dt>Title</dt>
<dd>$title</dd>
<dt>Artist</dt>
<dd><a href="http://aws.hail2u.net/?mode=music-jp&q=$artist_e">$artist</a></dd>
<dt>Album</dt>
<dd><a href="http://aws.hail2u.net/?mode=music-jp&q=$album_e">$album</a></dd>
</dl>
_HTML_
		}

		chomp $code;
		$self->{state}->{current_entry}->{Plugin}->{AMIP}->{stat} = $stat;
		$self->{state}->{current_entry}->{Plugin}->{AMIP}->{rendered} = $code;
	}
}

sub escape_special_characters {
	my $str = shift;

	chomp $str;
	$str =~ s/^\s*(.*?)\s*$/$1/;
	$str =~ s/&amp;/&/g;
	$str =~ s/&lt;/</g;
	$str =~ s/&gt;/>/g;
	$str =~ s/&quot;/"/g;
	$str =~ s/&apos;/'/g;
	$str =~ s/&#39;/'/g;
	$str =~ s/&/&amp;/g;
	$str =~ s/</&lt;/g;
	$str =~ s/>/&gt;/g;
	$str =~ s/"/&quot;/g;
	$str =~ s/'/&#39;/g;
	$str =~ s/&amp;#(\d+);/&#$1;/g;

	return $str;
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: AMIP

=head1 SYNOPSIS

Output NowPlaying code by html with AMIP.

=head1 REQUIREMENTS

Require AMIP Winamp/Apollo/QCD plugin. And you need to embed a ASIN code
to ID3v2 comment field if you wanna dance with Amazon Web Service.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::AMIP::render after Blosxom::run_entries in
   handlers.flow.

2. Put $Blosxom::Plugin::AMIP::rendered in head.flavour or foot.flavour.

=head1 EXAMPLES

Here is a sample data file:

  stat=Now listening to
  artist=Dashboard Confessional
  title=Living In Your Letters
  track=9
  album=MTV Unplugged v2.0
  year=2002
  comment=B00006RY8F
  genre=Rock

Here is a sample template for AMIP:

  stat=Recentry listened to
  artist=%1
  title=%2
  track=%3
  album=%4
  year=%5
  comment=%6
  genre=%7

=head1 VERSION

2004-05-09

Added documentation

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

I don't support anything.

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

=cut
