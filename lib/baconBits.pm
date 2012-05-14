package baconBits;

use 5.010;
use strict;
use warnings;
use Moose;

use LWP::UserAgent;
use HTTP::Cookies;

use baconBits::InfoBuilder;
use baconBits::TorrentBuilder;

=head1 NAME

baconBits - The great new baconBits!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use baconBits;

    my $foo = baconBits->new();
    ...


=head1 MEMBERS

=head2 username

baconBits username, required

=cut

has 'username' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

=head2 password

baconBits password, required

=cut

has 'password'  => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    trigger     => \&_login,
);

=head2 tracker_url

personal tracker url required

=cut

has 'tracker_url' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has 'login_url' => (
    is          => 'ro',
    isa         => 'Str',
    default     => 'https://baconbits.org/login.php',
);

has 'upload_url' => (
    is          => 'ro',
    isa         => 'Str',
    default     => 'https://baconbits.org/upload.php',

);

=head2 save_dir

directory to save files to

=cut

has 'save_dir' => (
    is          => 'rw',
    isa         => 'Str',
    default     => '~/',
);

has 'monitored_dir' => (
    is          => 'rw',
    isa         => 'Str',
    lazy        => 1,
    default     => '~/Downloads',
);

=head2 TorrentBuilder

object for building torrents

=cut

has 'TorrentBuilder' => (
    is      => 'ro',
    isa     => 'baconBits::TorrentBuilder',
    lazy    => 1,
    default => sub { baconBits::TorrentBuilder->new({ 
                            tracker_url => $_[0]->tracker_url, 
                            save_dir    => $_[0]->save_dir,
                    }) 
    },
    handles => qr/^(?:create_torrent)/,
);

=head2 InfoBuilder

object for building nfo and info files.

=cut

has 'InfoBuilder' => (
    is      => 'ro',
    isa     => 'baconBits::InfoBuilder',
    default => sub { baconBits::InfoBuilder->new },
    handles => qr/^(?:build_*)/,
);

# "Pretend" we're a web browser
has '_user_agent' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6; whatever, I\'m lying, I\'m really baconBits.pm',
);

has 'ua' => (
    is  => 'rw',
    isa => 'LWP::UserAgent',
    lazy    => 1,
    default => sub { my $agent = LWP::UserAgent->new; $agent->agent($_[0]->_user_agent); $agent; },
    handles => {
        post                => 'post',
        get                 => 'get',
        agent_cookie_jar    => 'cookie_jar'
    }
);

has 'cookie_jar' => (
    is => 'rw',
    isa => 'HTTP::Cookies',
    lazy => 1,
    default => sub { HTTP::Cookies->new },  
);


=head1 SUBROUTINES/METHODS

=head1 login

logs in

=cut

sub _login {
    my $self = shift;

    my $response = $self->post($self->login_url,
        {
            username    => $self->username,
            password    => $self->password,
        }
    );

    $self->_set_cookie($response);
}

sub _set_cookie {
    my $self        = shift;
    my $response    = shift;

    $self->cookie_jar->extract_cookies ($response);
    $self->agent_cookie_jar ($self->cookie_jar);
}

=head2 upload

uploades torrent

=cut

sub upload {
    my $self = shift;

    my $source_dir = shift;
    my $series = shift;    
    my $episode = shift;

    my $tags    = shift || 'mp3,avi';
    my $type    = shift || 'TV';

    # find file name of an avi,mkv or mp4 file
    my $file_name;
    opendir my ($DIRH), $source_dir;
    while (my $file = readdir $DIRH) {
        $file_name = $file if $file =~ m/(?:avi|mkv|mp4)/i;
    }
    # set torrent name
    my $torrent_name        = $file_name;
    $torrent_name           =~ s/(?:avi|mkv|mp4)/torrent/;
    my $title               = $file_name;
    $title                  =~ s/(?:\.avi|\.mkv|\.mp4)//;

    # set "source file"
    my $source_file = $source_dir . '/' . $file_name;

    # get episode indes from file name
    $episode = $file_name =~/(S\d\dE\d\d)/i unless $episode;
    
    $self->build_nfo($source_file);
    $self->create_torrent($torrent_name, $source_dir);

    my $description = $self->build_description($source_file, $episode, $series);

    my $response = $self->_do_upload($title, $tags, $description, $type, $self->save_dir . '/' . $torrent_name);
}

sub _do_upload {
    my $self = shift;

    my $response = $self->post($self->upload_url,
        {
            "title"         => $_[0], 
            "tags"          => $_[1],
            "desc"          => $_[2],
            "type"          =>  $_[3],
            "image"         => "", #change this yourself
            "submit"        => 1,
            "scene"         => 1,
            "file_input"    => $_[4],
        },
    );    
}


=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

three18ti, C<< <three18ti at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-baconbits at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=baconBits>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc baconBits


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=baconBits>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/baconBits>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/baconBits>

=item * Search CPAN

L<http://search.cpan.org/dist/baconBits/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 three18ti.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

no Moose;
__PACKAGE__->meta->make_immutable;
1; # End of baconBits
__END__

