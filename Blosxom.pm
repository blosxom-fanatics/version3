#!/usr/bin/perl

# Blosxom
# Author: Rael Dornfest <rael@oreilly.com>
# Version: 3.0+3i
# Home/Docs/Licensing: (Please see the data directory in this package) 
# and http://www.blosxom.com/

package Blosxom;

use strict;

use FileHandle;
use File::Spec;

# Blosxom New

sub new {
	my $class = shift;
	my $self = bless { }, $class;
	$self->init();
	return $self;
}

# Blosxom Initializer

sub init {
	my $self = shift;
	$self->{about}->{VERSION} = '3.0+3i';
	
	$self->{settings} = {};
	
	$self->{request} = {};
	
	$self->{state} = {};
	
	$self->{entries} = {};
	$self->{directories} = {};
	$self->{others} = {};

	$self->{handlers} = { flow => [], entry => [] };

	$self->{templates} = {};
	$self->{rendered} = {};
	
	$self->{response} = {};
	
	1;
}

# Accessor Methods

sub settings {
	my ($self, $settings) = @_;
	
	ref $settings eq 'HASH' and $self->{settings} = $settings;
	
	return $self->{settings};
}
	
# Handle Flow

sub run_flow {
	my $self = shift;

	$self->{state}->{stop}->{handlers}->{flow} = 0;
	
	no strict qw/subs refs/;
	foreach my $handler ( @{$self->{handlers}->{flow}} ) {

		last if $self->{state}->{stop}->{handlers}->{flow};

		&$handler($self);
	}
	use strict qw/subs refs/;
	
	1;
} 

# Handle Entries

sub run_entries {
	my $self = shift;
	
	$self->{state}->{stop}->{entries} = 0;

	no strict qw/subs refs/;
	foreach my $entry_id ( @{$self->{entries_sorted}} ) {
	
		last if $self->{state}->{stop}->{entries};
		
		$self->{state}->{stop}->{handlers}->{entry} = 0;
		
		$self->{state}->{current_entry} = $self->{entries}->{$entry_id};
		
		foreach my $handler ( @{$self->{handlers}->{entry}} ) {
			last if $self->{state}->{stop}->{handlers}->{entry};
			&$handler($self);
		}
	}
	use strict qw/subs refs/;
	
	1;
} 

# Default Flow Handlers

sub parse_request {
	my $self = shift;

	use CGI;
	
	$self->{cgi} = new CGI;
	
	$self->{request}->{url} ||= $self->{cgi}->url();
	$self->{request}->{url} =~ s/^included:/http:/; # Fix for Server Side Includes (SSI)
	$self->{request}->{url} =~ s!/$!!; # drop trailing slash

	my @path_info = split m{/}, 
		$self->{cgi}->path_info() || $self->{cgi}->param('path'); 
	shift @path_info; # drop initial blank
	
	# path_info
	
	$self->{request}->{path_info} = undef;
	while (
	 $path_info[0] and 
	 $path_info[0] =~ /^[a-zA-Z].*$/ and 
	 $path_info[0] !~ /(.*)\.(.*)/
	) { 
		$self->{request}->{path_info} .= '/' . shift @path_info; 
	}
	
	# flavour
	# as specified by ?flav=xyz or index.xyz
	
	$self->{request}->{flavour} = undef;
	if ( $path_info[$#path_info] =~ /(.+)\.(.+)$/ ) {
		($self->{request}->{entry}, $self->{request}->{flavour}) = ($1, $2);
		$1 ne 'index' and $self->{request}->{path_info} .= "/$1.$2"; # specific entry requested
		pop @path_info; # drop the entry/index and flavour bits
	} 
	else {
  		$self->{request}->{flavour} = 
  			$self->{cgi}->param('flav') || $self->{settings}->{default_flavour};
  	}

	# Strip spurious slashes and prepend a default /
	$self->{request}->{path_info} =~ s!(^/*)|(/*$)!!g;
	$self->{request}->{path_info} =~ s!^!/!;

	# Date
	
	@{$self->{request}}{'yr','mo_num','da'} = @path_info;

	# query_string
	
	$self->{request}->{query_string} = $self->{cgi}->query_string();

	1;

}

sub find_settings_and_handlers {
	my $self = shift;

	($self->{handlers}->{found}->{flow}, $self->{handlers}->{found}->{entry}, $self->{settings}->{found}) = ([], [], []);

	my @path_info_components = split /\//, $self->{request}->{path_info};
	my $current_path = $self->{settings}->{find_entries_dir};

	do {
		my $fn;
		($fn = File::Spec->catfile($current_path, $self->{settings}->{settings_subdir}, "settings")) && -e $fn && push @{$self->{settings}->{found}}, $fn;
		($fn = File::Spec->catfile($current_path, $self->{settings}->{settings_subdir}, "settings.".$self->{request}->{flavour})) && -e $fn && push @{$self->{settings}->{found}}, $fn;
		($fn = File::Spec->catfile($current_path, $self->{settings}->{settings_subdir}, "handlers.entry")) && -e $fn && push @{$self->{handlers}->{found}->{entry}}, $fn;
		($fn = File::Spec->catfile($current_path, $self->{settings}->{settings_subdir}, "handlers.entry.".$self->{request}->{flavour})) && -e $fn && push @{$self->{handlers}->{found}->{entry}}, $fn;
		($fn = File::Spec->catfile($current_path, $self->{settings}->{settings_subdir}, "handlers.flow")) && -e $fn && push @{$self->{handlers}->{found}->{flow}}, $fn;
		($fn = File::Spec->catfile($current_path, $self->{settings}->{settings_subdir}, "handlers.flow.".$self->{request}->{flavour})) && -e $fn && push @{$self->{handlers}->{found}->{flow}}, $fn;
	} while ( scalar @path_info_components and $current_path = File::Spec->catfile($current_path, shift @path_info_components) );

	1;
}

sub handle_settings {
	my $self = shift;

	# Preserve original settings just in case (also useful for static rendering)
	$self->{settings_original} ||= $self->{settings};

	$self->{state}->{filehandle} ||= new FileHandle;
	
	my $fh = $self->{state}->{filehandle};
	
	my @path_info_components = split /\//, $self->{request}->{path_info};
	my $current_path = $self->{settings}->{find_entries_dir};
	
	foreach my $settings_file ( @{$self->{settings}->{found}} ) {
		if ( $fh->open("< $settings_file") ) { 
			while ( my $s = <$fh> ) {
				chomp $s;
				$s =~ /^([\w:]+)\s*=\s*(.+)$/ and $self->{settings}->{$1} = $2;
			}
			$fh->close();
		}
	}

	1;
}

sub handle_handlers {
	my $self = shift;

	# Preserve original settings just in case (also possibly useful for static rendering)
  $self->{handlers_original}->{flow} = $self->{handlers}->{flow};
  $self->{handlers_original}->{entry} = $self->{handlers}->{entry};

	$self->{state}->{filehandle} ||= new FileHandle;
	
	my $fh = $self->{state}->{filehandle};
	
	my @path_info_components = split /\//, $self->{request}->{path_info};
	my $current_path = $self->{settings}->{find_entries_dir};
	
	HANDLER_TYPE: foreach my $handler_type ( ('flow', 'entry') ) {
		HANDLER_FILE: foreach my $handler_file ( reverse @{$self->{handlers}->{found}->{$handler_type}} ) {
			if ( $fh->open("< $handler_file") ) { 
				$self->{handlers}->{$handler_type} = [];
				while ( my $s = <$fh> ) {
					chomp $s;
					$s =~ /^[^#\s]/ and push @{$self->{handlers}->{$handler_type}}, $s;
				}
				$fh->close();
				last HANDLER_FILE;
			}
		}
	}

	1;
}

sub get_plugins {
	my $self = shift;

	if ( defined $self->{settings}->{plugin_dir} and 
		opendir PLUGINS, $self->{settings}->{plugin_dir} ) {
		foreach my $plugin ( grep { /^\w+\.pm$/ && -f File::Spec->catfile($self->{settings}->{plugin_dir}, $_)  } sort readdir(PLUGINS) ) {
			require File::Spec->catfile($self->{settings}->{plugin_dir}, $plugin);
		}
	  closedir PLUGINS;
	}

	1;
}

sub get_template {
	my $self = shift;
	
	my $component = shift;
	
	my $path = $self->{request}->{path_info};
	
	# Default Settings
	$self->{settings}->{find_entries_dir} ||= '.'; 

	exists $self->{templates}->{ $self->{request}->{flavour} }->{$component} and 
		return $self->{templates}->{ $self->{request}->{flavour} }->{$component};
		
	$self->{state}->{filehandle} ||= new FileHandle;
	my $fh = $self->{state}->{filehandle};


	do {
		if ( $fh->open("< " . File::Spec->catfile($self->{settings}->{find_entries_dir}, $path, $self->{settings}->{templates_subdir}, "$component.$self->{request}->{flavour}") ) ) {
			chomp($self->{templates}->{ $self->{request}->{flavour} }->{$component} = join '', <$fh>);
			return $self->{templates}->{ $self->{request}->{flavour} }->{$component};
		}
	} while ($path =~ s/(\/*[^\/]*)$// and $1);
    
	0;	
}

sub find_entries {
	my $self = shift;

	use File::Find;
	use File::stat;

	# Default Settings
	$self->{settings}->{find_entries_dir} ||= '.'; 
	$self->{settings}->{find_entries_depth} ||= 0; 
	$self->{settings}->{find_entries_ext} ||= 'txt'; 

	find(
		sub {
			my $curr_depth = $File::Find::dir =~ tr[/][]; 

			return if $self->{settings}->{find_entries_depth} and 
				$curr_depth > $self->{settings}->{find_entries_depth};
				
			$self->{directories}->{$File::Find::dir} = {id=>$File::Find::dir,};
			
			my($path) = $File::Find::dir =~ /$self->{settings}->{find_entries_dir}(.*)$/;
				
			# Strip spurious slashes and prepend a default /
			$path =~ s!(^/*)|(/*$)!!g;
			$path =~ s!(^|$)!/!g;
			
			if ( $_ !~ /^\.|index/ and 
			  $_ =~ /(.*)\.$self->{settings}->{find_entries_ext}$/ 
			) {
				$self->{entries}->{$File::Find::name} = {
					id=>$File::Find::name, 
					path_absolute=>$File::Find::dir, 
					path=>$path,
					filename=>$_,
					fn=>$1,
					mtime=>stat($File::Find::name)->mtime,
					inode=>stat($File::Find::name)->ino,
				};
			}
			elsif ( -d $File::Find::name ) {
				$self->{others}->{$File::Find::name} = {
					id=>$File::Find::name, 
					path_absolute=>$File::Find::dir, 
					path=>$path,
					filename=>$_, 
				};
			}
			
		}, 
		$self->{settings}->{find_entries_dir}
	);

	1;     	
}

sub sort_entries {
	my $self = shift;

	$self->{entries_sorted} = [ 
		sort { 
			$self->{entries}->{$b}->{mtime} <=> 
			$self->{entries}->{$a}->{mtime} 
		} keys %{$self->{entries}} 
	];

	1;	
}

sub shortcut_max_entries {
	my $self = shift;
	
	++$self->{state}->{current_entry_number} >= $self->{settings}->{max_entries} and $self->{state}->{stop}->{entries}++, return 0;

	1;
}

sub filter_entry_by_path {
	my $self = shift;
	
	unless (
		$self->{state}->{current_entry}->{path} =~ /^$self->{request}->{path_info}/ 
		or $self->{request}->{path_info} eq File::Spec->catfile($self->{state}->{current_entry}->{path}, $self->{state}->{current_entry}->{fn}).'.'.$self->{request}->{flavour}) {
			$self->{state}->{stop}->{handlers}->{entry}++, return 0;
	}
	
	1;
}

sub filter_entry_by_date {
	my $self = shift;

	defined $self->{request}->{yr} and $self->{state}->{current_entry}->{yr} ne $self->{request}->{yr} and $self->{state}->{stop}->{handlers}->{entry}++, return 0;
	defined $self->{request}->{mo_num} and $self->{state}->{current_entry}->{mo_num} ne $self->{request}->{mo_num} and $self->{state}->{stop}->{handlers}->{entry}++, return 0;
	defined $self->{request}->{da} and $self->{state}->{current_entry}->{da} ne $self->{request}->{da} and $self->{state}->{stop}->{handlers}->{entry}++, return 0;
	
	1;
}

sub read_entry_file {
	my $self = shift;

	$self->{state}->{filehandle} ||= new FileHandle;
	my $fh = $self->{state}->{filehandle};
	
	if (
	  -f $self->{state}->{current_entry}->{id} and 
	  $fh->open($self->{state}->{current_entry}->{id})
	) {
        chomp($self->{state}->{current_entry}->{title} = <$fh>);
        chomp($self->{state}->{current_entry}->{body} = join '', <$fh>);
        $fh->close;
	}

	1;
}

sub build_entry_date {
	my $self = shift;
	
	use Time::localtime;
	
	$self->{util}->{month2num} = { nil=>'00', Jan=>'01', Feb=>'02', Mar=>'03', Apr=>'04', May=>'05', Jun=>'06', Jul=>'07', Aug=>'08', Sep=>'09', Oct=>'10', Nov=>'11', Dec=>'12' };
	$self->{util}->{num2month} = [ sort { $self->{util}->{month2num}->{$a} <=> $self->{util}->{month2num}->{$b} } keys %{$self->{util}->{month2num}} ];

	my $ctime = ctime(
		$self->{entries}->{ 
			$self->{state}->{current_entry}->{id} 
		}->{mtime}
	);
	
	@{$self->{state}->{current_entry}}{'dw','mo','da','hr24','min','sec','yr'} = 
		( $ctime =~ /(\w{3}) +(\w{3}) +(\d{1,2}) +(\d{2}):(\d{2}):(\d{2}) +(\d{4})$/ );
	$self->{state}->{current_entry}->{da} = sprintf("%02d", $self->{state}->{current_entry}->{da});

 	$self->{state}->{current_entry}->{mo_num} = 
		$self->{util}->{month2num}->{ 
			$self->{state}->{current_entry}->{mo} 
		};
		
	$self->{state}->{current_entry}->{ampm} = 'am'; 	
	($self->{state}->{current_entry}->{hr}) = $self->{state}->{current_entry}->{hr24} =~ /^0?(\d+)$/;
	$self->{state}->{current_entry}->{hr} ||= 12;
	$self->{state}->{current_entry}->{hr} > 12 and $self->{state}->{current_entry}->{hr} -= 12, $self->{state}->{current_entry}->{ampm} = 'pm';
		
	1;
}

sub render_entry {
	my $self = shift;

	$self->{rendered}->{ $self->{state}->{current_entry}->{inode} } 
		and $self->{state}->{stop}->{handlers}->{entry}++, return 0;

	my $template = $self->get_template('entry');

	$self->{entries}->{ $self->{state}->{current_entry}->{id} }->{rendered} =
		$self->interpolate($template);

	$self->{rendered}->{ $self->{state}->{current_entry}->{inode} }++;
	
	push @{$self->{response}->{entries}}, 		
		$self->{state}->{current_entry}->{id};
		
	1;		
}

sub render_date {
	my $self = shift;

	my $yrmoda = $self->{state}->{current_entry}->{yr} . $self->{state}->{current_entry}->{mo} . $self->{state}->{current_entry}->{da};

	if ( $yrmoda ne $self->{state}->{current_date} ) {
		$self->{state}->{current_date} = $yrmoda;
		my $template = $self->get_template('date');
		return $self->interpolate($template);
	}

	undef;
}

sub interpolate {
	my $self = shift;
	my $template = shift;

	$template =~ s/\$([\w:]+)/_interpolate($self->{state}->{current_entry}, $1) || $self->{settings}->{$1} || $self->{request}->{$1}/ge;
		
	return $template;
}

sub _interpolate {
	my( $hash, $var ) = @_;

	my @tiers = split /::/, $var;

	foreach my $tier ( @tiers[0..$#tiers] ) {
		$hash = $hash->{ $tier };
	}

	$hash;
}

sub render_response {
	my $self = shift;
		
	foreach my $component ( qw/ content_type head foot / ) {
		my $template = $self->get_template($component);
		$self->{response}->{$component}->{rendered} = 
			$self->interpolate($template);
	}
	
	1;
}

sub output_header {
	my $self = shift;

	print $self->{cgi}->header( $self->{response}->{content_type}->{rendered} );
	
	1;
}

sub output_response {
	my $self = shift;
	
	print $self->{response}->{head}->{rendered};
	foreach ( @{$self->{response}->{entries}} ) {
		$self->{state}->{current_entry} = $self->{entries}->{$_};
		print $self->render_date(), $self->{entries}->{$_}->{rendered};
	}
	print $self->{response}->{foot}->{rendered};

	1;
}

#####DEBUG#####

sub dump {
	use Data::Dumper;
	my $self = shift;
	print Dumper $self;
	
	1;
}

# Main

# You shouldn't need to muck about in here at all. Alter settings, 
# flow and entry handlers in the settings, handlers.flow, and 
# handlers.entry, respectively. You can also define flavour-specific
# versions as settings.flavourname, handlers.flow.flavourname, and
# handlers.entry.flavourname.

if (!$INC{'Blosxom.pm'}) {

	package main;
	
	default:
	
		my $blosxom = new Blosxom;
		
		my $settings = {
			blog_title          => 'blosxom',
			blog_description    => 'yet another blosxom blog',
			blog_language       => 'en',
			url                 => '',
			basedir             => File::Spec->rel2abs('.'),
			find_entries_dir    => File::Spec->catfile(File::Spec->rel2abs('.'), 'data'),
			plugin_dir          => File::Spec->catfile(File::Spec->rel2abs('.'), 'plugins'),
			max_entries         => 15,
			plugin_dir          => File::Spec->catfile(File::Spec->rel2abs('.'), 'plugins'),
			state_dir           => File::Spec->catfile(File::Spec->rel2abs('.'), 'state'),
			settings_subdir	    => '.settings',
			templates_subdir    => '.templates',
			default_flavour     => 'html',
		};

		$blosxom->settings($settings);
				
		$blosxom->{handlers}->{flow} = [
			'Blosxom::get_plugins', # blosxom 3 plugins, that is
			'Blosxom::parse_request',
			'Blosxom::find_settings_and_handlers',
			'Blosxom::handle_settings',
			'Blosxom::handle_handlers',
			'Blosxom::find_entries',
			'Blosxom::sort_entries',
			'Blosxom::run_entries',
			'Blosxom::render_response',
			'Blosxom::output_header',
			'Blosxom::output_response',
		];

		$blosxom->{handlers}->{entry} = [
			'Blosxom::filter_entry_by_path',
			'Blosxom::build_entry_date',
			'Blosxom::filter_entry_by_date',
			'Blosxom::read_entry_file',
			'Blosxom::shortcut_max_entries',
			'Blosxom::render_entry',
		];
		
		$blosxom->run_flow();
		
}

1;

__END__

Changes in 3.0+3i:

* Tag plugin
* Meta plugin
* EntryType plugin
* Interpolation of variables at depth (e.g. $Plugin::Meta::via as $self->{state}->{current_entry}->{Plugin}->{Meta}->{via} ) -- thanks to brian d foy for _interpolate()
* Subdirectories (configurable; set to '' to remove) for settings (.settings for settings*, handlers*) and template (.templates for flavour components, themes, etc) at each step in the hierarchy to keep them separate from entries.
* Symbolic link support (via inode - not necessarily best for cross-platform, but we'll see)
* Moved get_plugins to the top of the flow handler list

Changes in 3.0+2i:

* Fixed permalinking (i.e. specific entry requested)
* Normalized (finally!) $self->{entries}->{}->{path} such that no path is / and a path is /a/path/

_______

To do in 3.0+4i

* theme as part of template sub?
* interpolate fancy as default interpolation (with backward compat)?
* licensing (for alpha, so as to stem derivs, etc until baked,  using http://creativecommons.org/licenses/by-nd-nc/1.0/)

