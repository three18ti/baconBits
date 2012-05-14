package baconBits::InfoBuilder;

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

#has 'source_dir' => (
#    is          => 'ro',
#    isa         => 'Str',
#    required    => 1,
#);

=cut

sub build_nfo {
    my $self = shift;

    my $source_file = shift;

    my $nfo_file = $source_file;
    $nfo_file =~ s/(?:avi|mkv|mp4)/nfo/;

    my $command = 'mediainfo '
        . $source_file
        . ' > ' . $nfo_file;
    return -e $nfo_file ? 1 : 0;
}

sub build_description {
    my $self = shift;

    my $source_file = shift;
    my $episode     = shift;
    my $series      = shift;

    my $screen_shots = shift || 3;
    
    my $command = 'pythonbits' 
        . ' -e ' . $episode  
        . ' -s ' . $screen_shots 
        . ' '   . $series
        . ' '   . $source_file;
    say $command;
    `$command`;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1; # End of baconBits
__END__

