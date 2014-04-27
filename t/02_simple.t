#!/usr/bin/perl

# Base tests.

use strict;
use Test::Spec;

use JSON::InFile;
use File::Temp ;

my $tmp_dir = File::Temp::tempdir( CLEANUP => 1 );
ok( (-d $tmp_dir), 'tmp dir created' );
my $fpath = File::Spec->catfile( $tmp_dir, 'infile-simple-test.json' );

describe "new fpath" => sub {
	my $struct = { a => "b", c => "d" };

	it "saved" => sub {
		JSON::InFile->new( fpath => $fpath, verbose_level => 1 )->save( $struct );
		ok(-f $fpath)
	};

	it "loaded" => sub {
		my $loaded_struct = JSON::InFile->new( fpath => $fpath, verbose_level => 1 )->load();
		is_deeply( $loaded_struct, $struct);
	};
};

describe "existing fpath" => sub {
	my $infile_obj = JSON::InFile->new( fpath => $fpath, verbose_level => 1 );
	# json length of $new_struct must be different to json length of $struct.
	my $new_struct = { x => "y", z => "zzzzzzz" };

	it "new saved" => sub {
		my $prev_fsize = (-s $fpath);
		$infile_obj->save($new_struct);
		my $new_fsize = (-s $fpath);
		ok($prev_fsize != $new_fsize);
	};

	it "new load" => sub {
		my $new_loaded_struct = JSON::InFile->new( fpath => $fpath, verbose_level => 1 )->load();
		is_deeply( $new_loaded_struct, $new_struct );
	};

};

runtests unless caller;
