package baconBits::TorrentBuilder;

use 5.010;
use strict;
use warnings;
use Moose;

=head1 NAME

baconBits::Torrent - Module to create torrent file

=cut

=head1 SYNOPSIS

Module used to create torrent files, should not be used directly.

=head1 MEMBERS

=head2 tracker_url

url of the tracker

=cut 

has 'tracker_url' => (
    is      => 'ro',
    isa     => 'Str',
    required => 1,
);

has 'save_dir'  => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

=head1 FUNCTIONS

=head2 create_torrent( $torrent_name, $source );

calls ctorrent to create the torrent file
executes:

    ctorrent -t -u tracker_url -s torrent_name source

=cut

sub create_torrent {
    my $self = shift;

    my $torrent_name    = shift;
    my $source_dir      = shift;

    # ctorrent -t -u tracker_url -s torrent_name source
    my $command = 'ctorrent -t' 
        . ' -u ' . $self->tracker_url 
        . ' -s ' . $self->save_dir . $torrent_name 
        . ' '    . $source_dir;
    my $result = `$command`;

    return $result =~ /successful/g ? 1 : grep {/error/} $result;
}



no Moose;
__PACKAGE__->meta->make_immutable;
1; # End of baconBits
__END__

