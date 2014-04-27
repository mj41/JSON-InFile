JSON::InFile
============

Perl module to save/load perl structure as JSON to/from file

Synopsis
--------

Save

	use JSON::InFile;
	my $struct = { some => "perl struct" };
	JSON::InFile->new(fpath => "/tmp/myinfile-struct.json", verbose_level => 10)->save( $struct );

Load

	use JSON::InFile;
	my $struct = JSON::InFile->new(fpath => "/tmp/myinfile-struct.json", verbose_level => 10)->load;
