package File::UnixAuth::Storage;

use namespace::autoclean;

use File::DataClass::Constants qw( FALSE NUL SPC TRUE );
use Moo;

extends q(File::DataClass::Storage);

# Public methods
sub read_from_file {
   my ($self, $rdr) = @_;

   $self->encoding and $rdr->encoding($self->encoding);

   return $self->_read_filter([$rdr->chomp->getlines]);
}

sub write_to_file {
   my ($self, $wtr, $data) = @_;

   $wtr->encoding($self->encoding) if $self->encoding;

   $wtr->println(@{$self->_write_filter($data)});

   return $data;
}

# Private methods
sub _deflate {
   my ($self, $hash, $id) = @_;

   my $attr  = $hash->{$id};
   my $gecos = NUL;

   $attr->{members} = join ',', @{$attr->{members} || []}
      if exists $attr->{members};

   $gecos .= $attr->{first_name} // NUL if exists $attr->{first_name};

   $gecos .= $attr->{last_name} ? SPC.$attr->{last_name} : NUL
      if exists $attr->{last_name};

   if ($attr->{location} || $attr->{work_phone} || $attr->{home_phone}) {
      $gecos .= ','.($attr->{location  } // NUL);
      $gecos .= ','.($attr->{work_phone} // NUL);
      $gecos .= ','.($attr->{home_phone} // NUL);
   }

   $attr->{gecos} = $gecos if $gecos;

   return;
}

sub _inflate {
   my ($self, $hash, $id) = @_;

   my $attr = $hash->{$id};

   $attr->{members} = [ split m{ , }mx, $attr->{members} // NUL ]
      if exists $attr->{members};

   if (exists $attr->{gecos}) {
      my @fields = qw( full_name location work_phone home_phone );

      @{$attr}{@fields} = split m{ , }mx, $attr->{gecos} // NUL;

      my $names = _parse_name($attr->{full_name});

      $attr->{first_name} = $names->{first_name} // NUL;
      $attr->{last_name } = $names->{last_name } // NUL;
      delete $attr->{full_name};
      delete $attr->{gecos};
   }

   return;
}

sub _read_filter {
   my ($self, $buf) = @_;

   my $hash        = {};
   my $order       = 0;
   my $source_name = $self->schema->source_name;
   my $fields      = $self->schema->source->attributes;

   for my $line (@{$buf || []}) {
      my ($id, @rest) = split m{ : }mx, $line;
      my %attr = ();

      @attr{@{$fields}} = @rest;
      $attr{_order_by} = $order++;
      $hash->{$id} = \%attr;
      $self->_inflate($hash, $id);
   }

   return { $source_name => $hash };
}

sub _write_filter {
   my ($self, $data) = @_;

   my $buf         = [];
   my $source_name = $self->schema->source_name;
   my $fields      = $self->schema->source->attributes;
   my $hash        = $data->{$source_name};

   $fields = [ @{$fields}[0 .. 5] ] if $source_name eq 'passwd';

   for my $id (sort { _original_order($hash, $a, $b) } keys %{$hash}) {
      $self->_deflate($hash, $id);

      my $attr = $hash->{$id};

      delete $attr->{_order_by};

      my $line = join ':', map { $attr->{$_} // NUL } @{$fields};

      push @{$buf}, "${id}:${line}";
   }

   return $buf;
}

# Private functions
sub _original_order {
   my ($hash, $lhs, $rhs) = @_;

   # New elements will be  added at the end
   return  1 unless exists $hash->{$lhs}->{_order_by};
   return -1 unless exists $hash->{$rhs}->{_order_by};
   return $hash->{$lhs}->{_order_by} <=> $hash->{$rhs}->{_order_by};
}

sub _parse_name {
   my $full_name = shift;

   return {} unless $full_name;

   my ($first_name, $last_name) = split SPC, $full_name, 2;

   return { first_name => $first_name, last_name => $last_name };
}

1;

__END__

=pod

=encoding utf-8

=head1 Name

File::UnixAuth::Storage - Unix authentication and authorisation file storage

=head1 Synopsis

   use File::UnixAuth::Storage;

=head1 Description

=head1 Configuration and Environment

=head1 Subroutines/Methods

=head2 read_from_file

=head2 write_to_file

=head1 Diagnostics

=head1 Dependencies

=over 3

=item L<File::DataClass::Storage>

=item L<MooX::Augment>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2021 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
