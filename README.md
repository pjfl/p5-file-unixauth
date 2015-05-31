<div>
    <a href="https://travis-ci.org/pjfl/p5-file-unixauth"><img src="https://travis-ci.org/pjfl/p5-file-unixauth.svg?branch=master" alt="Travis CI Badge"></a>
    <a href="http://badge.fury.io/pl/File-UnixAuth"><img src="https://badge.fury.io/pl/File-UnixAuth.svg" alt="CPAN Badge"></a>
    <a href="http://cpants.cpanauthors.org/dist/File-UnixAuth"><img src="http://cpants.cpanauthors.org/dist/File-UnixAuth.png" alt="Kwalitee Badge"></a>
</div>

# Name

File::UnixAuth - Read and write the Unix authentication files

# Version

Describes version v0.24.$Rev: 1 $ of [File::UnixAuth](https://metacpan.org/pod/File::UnixAuth)

# Synopsis

    use File::UnixAuth;

    my $unixauth_ref = File::UnixAuth->new( $unixauth_attributes );

# Description

Extends [File::DataClass::Schema](https://metacpan.org/pod/File::DataClass::Schema). Provides for the reading and
writing of the the Unix `/etc/group`, `/etc/passwd`, and
`/etc/shadow` files.

Since these files share a common format they all use the the same
storage class [File::UnixAuth::Storage](https://metacpan.org/pod/File::UnixAuth::Storage). Defines three result
sources; `group`, `passwd`, and `shadow`

# Configuration and Environment

Defines these attributes;

- `post_update_hook`

    A code reference that is called after an update completes. Defaults to
    `undef`. If set to:

        sub { qx( 'grpconv' ) }

    then the file `/etc/gshadow` will be updated

- `result_source_attributes`

    Defines the result sources and their attributes

- `source_name`

    A required string. Selects the required result source. Set to one of;
    `group`, `passwd`, or `shadow`

- `storage_attributes`

    Change the defaults to create a backup file with a `.bak` extension

Modifies these methods;

- `resultset`
- `source`

# Subroutines/Methods

None

# Diagnostics

None

# Dependencies

- [File::DataClass::Schema](https://metacpan.org/pod/File::DataClass::Schema)
- [File::UnixAuth::Result](https://metacpan.org/pod/File::UnixAuth::Result)
- [Moo](https://metacpan.org/pod/Moo)

# Incompatibilities

There are no known incompatibilities in this module

# Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2015 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/pod/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
