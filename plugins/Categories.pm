# Blosxom 3.0 Plugin: Categories
# Author: Kyo Nagashima <kyo@hail2u.net>
# Version: 2004-05-08

package Blosxom::Plugin::Categories;

use strict;

# --- Configurable variables -----------

# friendly name of directories
my %friendly_name = (
	'/'        => 'いっちゃんうえっぽい',
	'category' => 'かてごり',
	'flavour'  => 'ふれ～ば～',
	'plugin'   => 'ぷらっぐいん',
);

# separater string between each part of category
my $category_sep = " &#187; ";

# separator string between $blog_title and $category_title
my $title_sep = " - ";

# --- Plug-in package variables --------

my(%stories, %children, %seen);

# --------------------------------------

sub convert_path_to_category {
	my $self = shift;

	my $category;
	my $id = $self->{state}->{current_entry}->{id};

	foreach (split(m!/!, $self->{state}->{current_entry}->{path})) {
		next if !$_;
		$_ = $friendly_name{$_} if $friendly_name{$_};
		$category .= qq!$category_sep$_!;
	}

	$category =~ s!^$category_sep!!;
	$category = $friendly_name{'/'} unless $category;
	$self->{state}->{current_entry}->{Plugin}->{Categories}->{category} = $category;
}

sub generate_title {
	my $self = shift;

	if (!defined $self->{request}->{yr}
		and defined $self->{request}->{path_info}
		and $self->{request}->{path_info} !~ m!.*?/?[\w-]+\.[\w-]+$!) {
		my $title;

		foreach (split(m!/!, $self->{request}->{path_info})) {
			next if !$_;
			$_ = $friendly_name{$_} if $friendly_name{$_};
			$title .= qq!$category_sep$_!;
		}

		$title =~ s!^$category_sep!$title_sep!;
		$self->{state}->{current_entry}->{Plugin}->{Categories}->{title} = $title;
	}
}

sub render {
	my $self = shift;

	foreach my $id (keys %{$self->{entries}}) {
		my($path, $filename) = ($id =~ m!(.*)/(.*)!);
		$stories{$path}++;
		my $child;

		while ($path ne $self->{settings}->{find_entries_dir}) {
			($path, $child) = ($path =~ m!(.*)/(.*)!);
			$stories{$path}++;

			if (!$seen{"$path/$child"}++) {
				push @{$children{$path}}, $child;
			}
		}
	}

	my $categories = qq!<ul>\n!;
	$categories .= &report_dir_start($self, '', '/', $stories{"$self->{settings}->{find_entries_dir}"});

	foreach (sort @{$children{$self->{settings}->{find_entries_dir}}}) {
		$categories .= &report_dir($self, '/', $_);
	}

	$categories .= qq!</ul>\n</li>\n!;
	$categories .= qq!</ul>!;
	$self->{state}->{current_entry}->{Plugin}->{Categories}->{rendered} = $categories;
}

sub report_dir {
	my($self, $parent, $dir) = @_;

	my $results;
	my $datadir = $self->{settings}->{find_entries_dir};

	if (!defined $children{"$parent$dir"}) {
		$results = &report_dir_leaf($self, "$parent$dir", "$dir", $stories{"$datadir$parent$dir"});
	} else {
		$results = &report_dir_start($self, "$parent$dir", "$dir", $stories{"$datadir$parent$dir"});

		foreach my $child (sort @{$children{"$parent$dir"}}) {
			$results .= &report_dir($self, "$datadir$parent$dir/", $child);
		}

		$results .= qq!</ul>\n</li>\n!;
	}

	return $results;
}

sub report_dir_start {
	my($self, $path, $dir, $num) = @_;

	$num ||= 0;
	$dir = %friendly_name->{$dir} if %friendly_name->{$dir};

	return qq!<li><a href="$self->{settings}->{url}$path/" title="$dir">$dir</a> ($num)\n<ul>\n!;
}

sub report_dir_leaf {
	my($self, $path, $dir, $num) = @_;

	$num ||= 0;
	$dir = %friendly_name->{$dir} if %friendly_name->{$dir};

	return qq!<li><a href="$self->{settings}->{url}$path/" title="$dir">$dir</a> ($num)</li>\n!;
}

1;

__END__

=head1 NAME

Blosxom 3.0 Plugin: Categories

=head1 SYNOPSIS

Provide an unnumbered list of the categories (a.k.a. directories) with a
friendly name by html, a friendly name of category string separately for
putting into title element if visitors access category page, and
a friendly name of category for your entry.flavour.

=head1 INSTALLATION AND CONFIGURATION

1. Put Blosxom::Plugin::Categories::generate_title and
   Blosxom::Plugin::Categories::render after Blosxom::run_entries in
   handlers.flow.

2. Put Blosxom::Plugin::Categories::convert_path_to_category after
   Blosxom::read_entry_file in handlers.entry.

3. Put $Plugin::Categories::rendered and $Plugin::Categories::title
   in head.flavour or foot.flavour. And $Plugin::Categories::category
	 in entry.flavour.

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
