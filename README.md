# Name

File::UnixAuth - Domain model for the Unix authentication files

# Version

Describes version 0.16.$Rev: 1 $ of [File::UnixAuth](https://metacpan.org/module/File::UnixAuth)

# Synopsis

    use File::UnixAuth;

    my $unixauth_ref = File::UnixAuth->new( $unixauth_attributes );

# Description

Extends [File::DataClass::Schema](https://metacpan.org/module/File::DataClass::Schema). Provides for the reading and
writing of the the Unix `/etc/group`, `/etc/passwd`, and
`/etc/shadow` files.

Since these files share a common format they all use the the same
storage class [File::UnixAuth::Storage](https://metacpan.org/module/File::UnixAuth::Storage). Defines three result
sources; `group`, `passwd`, and `shadow`

# Configuration and Environment

Defines these attributes;

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

- [File::DataClass::Schema](https://metacpan.org/module/File::DataClass::Schema)
- [File::UnixAuth::Result](https://metacpan.org/module/File::UnixAuth::Result)
- [Moo](https://metacpan.org/module/Moo)

# Incompatibilities

There are no known incompatibilities in this module

# Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2013 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/module/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
