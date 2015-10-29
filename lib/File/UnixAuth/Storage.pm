package File::UnixAuth::Storage;

use namespace::autoclean;

use File::DataClass::Constants qw( FALSE NUL SPC TRUE );
use Moo;

extends q(File::DataClass::Storage);

# Private functions
my $_original_order = sub {
   my ($hash, $lhs, $rhs) = @_;

   # New elements will be  added at the end
   exists $hash->{ $lhs }->{_order_by} or return  1;
   exists $hash->{ $rhs }->{_order_by} or return -1;
   return $hash->{ $lhs }->{_order_by} <=> $hash->{ $rhs }->{_order_by};
};

my $_parse_name = sub {
   my $full_name = shift; $full_name or return {};

   my ($first_name, $last_name) = split SPC, $full_name, 2;

   return { first_name => $first_name, last_name => $last_name };
};

# Private methods
my $_deflate = sub {
   my ($self, $hash, $id) = @_; my $attr = $hash->{ $id }; my $gecos = NUL;

   exists $attr->{members   }
      and $attr->{members   } = join ',', @{ $attr->{members   } || [] };
   exists $attr->{first_name} and $gecos .=  $attr->{first_name} // NUL;
   exists $attr->{last_name } and $gecos .=  $attr->{last_name }
                                       ? SPC.$attr->{last_name }  : NUL;

   if ($attr->{location} or $attr->{work_phone} or $attr->{home_phone}) {
      $gecos .= ','.($attr->{location  } // NUL);
      $gecos .= ','.($attr->{work_phone} // NUL);
      $gecos .= ','.($attr->{home_phone} // NUL);
   }

   $gecos and $attr->{gecos} = $gecos;
   return;
};

my $_inflate = sub {
   my ($self, $hash, $id) = @_; my $attr = $hash->{ $id };

   exists $attr->{members}
      and $attr->{members} = [ split m{ , }mx, $attr->{members} // NUL ];

   if (exists $attr->{gecos}) {
      my @fields = qw( full_name location work_phone home_phone );

      @{ $attr }{ @fields } = split m{ , }mx, $attr->{gecos} // NUL;

      my $names  = $_parse_name->( $attr->{full_name} );

      $attr->{first_name} = $names->{first_name} // NUL;
      $attr->{last_name } = $names->{last_name } // NUL;
      delete $attr->{full_name}; delete $attr->{gecos};
   }

   return;
};

my $_read_filter = sub {
   my ($self, $buf) = @_; my $hash = {}; my $order = 0;

   my $source_name = $self->schema->source_name;
   my $fields      = $self->schema->source->attributes;

   for my $line (@{ $buf || [] }) {
      my ($id, @rest) = split m{ : }mx, $line; my %attr = ();

      @attr{ @{ $fields } } = @rest;
      $attr{ _order_by    } = $order++;
      $hash->{ $id } = \%attr;
      $self->$_inflate( $hash, $id );
   }

   return { $source_name => $hash };
};

my $_write_filter = sub {
   my ($self, $data) = @_; my $buf = [];

   my $source_name = $self->schema->source_name;
   my $fields      = $self->schema->source->attributes;
   my $hash        = $data->{ $source_name };

   $source_name eq 'passwd' and $fields = [ @{ $fields }[ 0 .. 5 ] ];

   for my $id (sort { $_original_order->( $hash, $a, $b ) } keys %{ $hash }) {
      $self->$_deflate( $hash, $id );

      my $attr = $hash->{ $id }; delete $attr->{_order_by};
      my $line = join ':', map { $attr->{ $_ } // NUL } @{ $fields };

      push @{ $buf }, "${id}:${line}";
   }

   return $buf;
};

# Public methods
sub read_from_file {
   my ($self, $rdr) = @_;

   $self->encoding and $rdr->encoding( $self->encoding );

   return $self->$_read_filter( [ $rdr->chomp->getlines ] );
}

sub write_to_file {
   my ($self, $wtr, $data) = @_;

   $self->encoding and $wtr->encoding( $self->encoding );
   $wtr->println( @{ $self->$_write_filter( $data ) } );

   return $data;
};

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

Copyright (c) 2015 Peter Flanigan. All rights reserved

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
