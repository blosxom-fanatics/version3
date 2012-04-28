# Blosxom 3.0 Plugin: 404
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::404;

use strict;

# --- Configurable variables -----------

my $source = <<"_HTML_";
<html>
<head>
<title>404 Not Found</title>
</head>
<body>
<h1>404 Not Found...</h1>
<p>んなものねぇよ。</p>
</body>
</html>
_HTML_

# --- Plug-in package variables --------

# --------------------------------------

sub check_and_output_header {
	my $self = shift;

	if ($#{$self->{response}->{entries}} < 0) {
		$self->{response}->{head}->{rendered} = $source;
		$self->{response}->{foot}->{rendered} = "";
		print $self->{cgi}->header(
			-type   => $self->{response}->{content_type}->{rendered},
			-status => "404 Not Found",
		);
	} else {
		$self->output_header($self);
	}
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: 404

=head1 SYNOPSIS

Output 404 document if no entries.

=head1 INSTALLATION AND CONFIGURATION

Replace Blosxom::output_header with
Blosxom::Plugin::404::check_and_output_header

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
