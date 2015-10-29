use t::boilerplate;

use Test::More;
use Test::Requires 'Hash::MoreUtils';
use Test::Requires { Moo => 2.000001 };
use English qw( -no_match_vars );
use File::DataClass::IO;
use File::Spec::Functions qw( catfile );
use Text::Diff;

use_ok 'File::UnixAuth';

my $args   = { path        => catfile( qw( t shadow ) ),
               source_name => 'shadow',
               tempdir     => 't' };
my $schema = File::UnixAuth->new( $args );

isa_ok $schema, 'File::UnixAuth';

my $dumped = catfile( qw( t dumped.shadow ) ); io( $dumped )->unlink;
my $data   = $schema->load;

$schema->dump( { data => $data, path => $dumped } );

my $diff = diff catfile( qw( t shadow ) ), $dumped;

ok !$diff, 'Shadow - load and dump roundtrips'; io( $dumped )->unlink;

$schema->dump( { data => $schema->load, path => $dumped } );

$diff = diff catfile( qw(t shadow) ), $dumped;

ok !$diff, 'Shadow - load and dump roundtrips 2'; io( $dumped )->unlink;

$args   = { path               => catfile( qw( t passwd ) ),
            source_name        => 'passwd',
            storage_attributes => { encoding => 'UTF-8', },
            tempdir            => 't' };
$schema = File::UnixAuth->new( $args );
$dumped = catfile( qw( t dumped.passwd ) ); io( $dumped )->unlink;
$data   = $schema->load;

$schema->dump( { data => $data, path => $dumped } );

$diff   = diff catfile( qw( t passwd ) ), $dumped;

ok !$diff, 'Passwd - load and dump roundtrips'; io( $dumped )->unlink;

$schema->dump( { data => $schema->load, path => $dumped } );

$diff = diff catfile( qw( t passwd ) ), $dumped;

ok !$diff, 'Passwd - load and dump roundtrips 2'; io( $dumped )->unlink;

$args   = { path        => catfile( qw( t group ) ),
            source_name => 'group',
            tempdir     => 't' };
$schema = File::UnixAuth->new( $args );

my $rs  = $schema->resultset; my $res = $rs->find( 'audio' );

is $res->members->[ 1 ], 'pjf', 'Finds group record';

$res->remove_user_from_group( 'pjf' ); $res = $rs->find( 'audio' );

is $res->members->[ 1 ], undef, 'Removes user from group';

$res->add_user_to_group( 'pjf' ); $res = $rs->find( 'audio' );

is $res->members->[ 1 ], 'pjf', 'Adds user to group';

done_testing;

# Cleanup
io( catfile( qw( t ipc_srlock.lck ) ) )->unlink;
io( catfile( qw( t ipc_srlock.shm ) ) )->unlink;
io( catfile( qw( t file-dataclass-schema.dat ) ) )->unlink;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
