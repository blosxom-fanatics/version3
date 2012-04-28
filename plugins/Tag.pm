# Blosxom 3.0+1i Plugin: Tag
# Filters entries by assigned tags
# 2004-04-29
# Rael Dornfest <rael@raelity.org>

package Blosxom::Plugin::Tag;

# --- Configurable variables -----

# What should I use as a separator between tags for display purposes?
my $tag_separator = ', ';

# --------------------------------

sub filter_entry_by_tag {
	my $self = shift;

	# Make any tags available to the template as $Plugin::Tag::tags
	if ( my($tags) = $self->{state}->{current_entry}->{fn} =~ /,(.+)$/ ) {
		if ( $tag_separator ne ',' ) {
			my @tags = split /,/, $tags;
			$self->{state}->{current_entry}->{Plugin}->{Tag}->{tags} = join $tag_separator, @tags;
		} else {
			$self->{state}->{current_entry}->{Plugin}->{Tag}->{tags} = $tags;
		}	
	}

	# No tags requested
	$self->{cgi}->param('tag') or return 0;

	my @tags = split /,+/, $self->{cgi}->param('tag');

	my $matches = 0;
	foreach my $tag ( @tags ) {
		my $key;

		# must-not-have
		if ( ($key) = $tag =~ /^\-(\w+)/ and $self->{state}->{current_entry}->{fn} =~ /,$key/ ) { 
			$self->{state}->{stop}->{handlers}->{entry}++; 
			return 0; 
		}

		# must-have
		if ( ($key) = $tag =~ /^ (\w+)/ ) {
			unless ( $self->{state}->{current_entry}->{fn} =~ /,$key/ ) { 
				$self->{state}->{stop}->{handlers}->{entry}++; 
				return 0
			} else {
				$matches++
			}
		}

		# may have
		if ( ($key) = $tag =~ /^(\w+)/ and $self->{state}->{current_entry}->{fn} =~ /,$key/ ) { 
			$matches++;
		}

	}

	$matches or $self->{state}->{stop}->{handlers}->{entry}++, return 0;

	1;
}

1;


__END__

=head1 NAME

Blosxom 3.0 Plugin: Tag

=head1 SYNOPSIS

This plugin allows arbitrary tags to be assigned to entries, either 
instead of or alongside Blosxom's native path-based categorization.
You can think of it as a personal, family, or workgroup  
del.icio.us [http://del.icio.us/].

Example 1.

Tag an entry called grandmas_cookie_recipe.txt as having something
to do with cookies, oatmeal, and raisins by naming the file:

  grandmas_cookie_recipe,cookies,oatmeal,raisins.txt

Example 2.

Tag an entry called grandpas_sausage_recipe.txt as having something
to do with sausages, spicy, and yummy by naming the file:

  grandpas_sausage_recipe,sausages,spicy,yummy.txt

--

The plugin then allows searching for these tags on the URL-line
by feeding a comma-separated list of optional, must-have, and must-not-have 
tags as a tag= parameter.

Example 1.

Find all entries tagged as cookies:

  http://.../?tag=cookies

returns:

  grandmas_cookie_recipe,cookies,oatmeal,raisins.txt

Example 2.

Find all entries tagged as cookies and/or sausages:

  http://.../?tag=cookies,sausages

returns: 

  grandmas_cookie_recipe,cookies,oatmeal,raisins.txt
  grandpas_sausage_recipe,sausages,spicy,yummy.txt

Example 3. 

Find all entries tagged as cookies, not tagged as sausages:

  http://.../?tag=cookies,-sausages

returns: 

  grandmas_cookie_recipe,cookies,oatmeal,raisins.txt

Example 4.

Find all entries tagged as cookies and/or sausages, but only if
also tagged as yummy:

  http://.../?tag=cookies,sausages,+yummy

returns:

  grandpas_sausage_recipe,sausages,spicy,yummy.txt

Example 5.

Find all entries tagged as cookies and/or sausages, only if
also tagged as yummy, and not tagged as spicy:

  http://.../?tag=cookies,sausages,+yummy,-spicy

returns nothing.

=head1 INSTALLATION

Drop Tag into your Blosxom 3.0 plugins directory and add it to the 
handlers.entry configuration file in your Blosxom 3.0 data directory. 
You can put it either alongside or instead of Blosxom's built-in 
filter_entry_by_path.

 * Use it instead of if you're not going to be using paths at all.

   ...
   Blosxom::Plugin::Tag::filter_entry_by_tag
   ...

 * Use it alongside otherwise. 

   ...
   Blosxom::filter_entry_by_path
   Blosxom::Plugin::Tag::filter_entry_by_tag
   ...

If alongside, whether you put Tag before or after filter_entry_by_path
should be based upon how people use your site. If they'll be using
tags more, put it before; if browsing paths, put it after.

=head1 CONFIGURATION

None necessary.

=head1 VERSION

2003-04-29

Version number is the date on which this version of the plug-in was created.

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

