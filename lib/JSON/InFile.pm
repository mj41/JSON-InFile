package JSON::InFile;

use strict;
use warnings;
use Carp qw(carp croak verbose);

use File::Spec;
use JSON::XS;

sub new {
	my ( $class, %args ) = @_;
	my $self = {};
	$self->{vl} = $args{verbose_level} // 3;
	$self->{fpath} = $args{fpath} || croak "Parameter 'fpath' is mandatory.\n";
	$self->{json_obj} = $args{json_obj} // new_json_obj();
	bless $self, $class;
}

sub new_json_obj {
	return JSON::XS->new->canonical(1)->pretty(1)->utf8(0)->relaxed(1);
}

sub json_obj {
	my $self = shift;
	return $self->{json_obj};
}

sub fpath {
	my $self = shift;
	return $self->{fpath};
}

sub json2struct {
	my ( $self, $struct ) = @_;
	return $self->json_obj->decode( $struct );
}

sub load_json {
    my ( $self ) = @_;

    my $fpath = $self->fpath;
    croak "File '$fpath' not found.\n" unless -f $fpath;

	my $json;
    {
		local $/;
		open( my $fh, '<:utf8', $fpath )
			|| croak "Can't open '$fpath': $!\n";
		$json = <$fh>;
	}
	return $json;
}

sub load {
    my ( $self ) = @_;
	print "Loading struct from file '".$self->fpath()."'.\n" if $self->{vl} >= 4;
    my $json = $self->load_json();
    return $self->json2struct($json);
}

sub struct2json {
	my ( $self, $struct ) = @_;
	return $self->json_obj->encode( $struct );
}

sub save {
	my ( $self, $struct, %args ) = @_;
	$args{save_if_changed} //= 1;

	my $fpath = $self->fpath;

	my $json = $self->struct2json( $struct );

	# file exists
	if ( -f $fpath ) {
		# check if changedd
		if ( $args{save_if_changed} ) {
			# file exists - change not found
			if ( $json eq $self->load_json() ) {
				print "Save of struct to '$fpath' skipped (change not found).\n" if $self->{vl} >= 4;;
				return 1;
			}
			# file exists - change found
			print "Saving struct to '$fpath' (change found).\n" if $self->{vl} >= 4;
		# do not check if changed
		} else {
			print "Saving struct to '$fpath' (force rewrite).\n" if $self->{vl} >= 4;
		}

	# file doesn't exist yet
	} else {
		print "Saving struct to '$fpath' (new file).\n" if $self->{vl} >= 4;
	}

    open( my $fh, '>:utf8', $fpath )
		|| croak "Can't open '$fpath' for write:$!\n";
    print $fh $json;
    close($fh) || croak "Close/write of '$fpath' failed: $!\n";
    return 1;
}

1;