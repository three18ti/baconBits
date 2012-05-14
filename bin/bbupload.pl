#!/usr/bin/perl
use Data::Dumper;

use 5.010;
use strict;
use warnings;

use Getopt::Long;
use Config::Any;

use lib './lib';
use baconBits;

my ($password, $username, $source_dir, $help, $verbose, $need_help, $config_file, $tracker_url, $delay, $monitored_dir, $save_dir, $episode, $series);
my $delay_default = 60;

GetOptions (
    'c|config=s'        => \$config_file,
    'd|delay=s'         => \$delay,
    'e|episode=s'       => \$episode,
    'm|monitored=s'     => \$monitored_dir,
    'p|password=s'      => \$password,
    'r|series=s'        => \$series,
    's|source=s'        => \$source_dir,
    't|tracker=s'       => \$tracker_url,
    'a|save-dir=s'      => \$save_dir,
    'u|username=s'      => \$username,
    'v|verbose+'        => \$verbose,
    'h|help'            => \$need_help,
);

# set config file and load it
$config_file = './etc/test.baconbits.yml' unless $config_file;
# my $config_file = '/etc/baconbits.yml' ;

# $load the config file, if it exists.
my $cfg;
if (-e $config_file) {
    $cfg = Config::Any->load_files({ files => [$config_file], use_ext => 1 })->[0]->{$config_file};
}
else {
    say "No config file found, so none loaded" if $verbose;
}

#print Dumper $cfg;

# load settings from config unless already set at commandline
$username       = $cfg->{'account'}->{'username'}       unless $username;
$password       = $cfg->{'account'}->{'password'}       unless $password;
$tracker_url    = $cfg->{'trackerurl'}                  unless $tracker_url;
$monitored_dir  = $cfg->{'directories'}->{'monitored'}  unless $monitored_dir;
$save_dir       = $cfg->{'directories'}->{'save'}       unless $save_dir;

#set delay from the config file
$delay          = $cfg->{'delay'}                       unless $delay;
# set delay to default unless it is set previously
$delay          = $delay_default                        unless $delay;

# print help and exit if source has not been set
if(!$source_dir or $need_help){
    print_help();
    exit 0;
}

# create new baconBits object, automagically handles login
my $bB = baconBits->new({
    tracker_url     => $tracker_url,
    username        => $username,
    password        => $password,
    monitored_dir   => $monitored_dir,
    save_dir        => $save_dir,
});

# create torrent file and upload it
my $response = $bB->upload($source_dir, $series, $episode);

print Dumper $response->content;

# I've been having trouble when I immidiately download a torrent I have uploaded
# by introducing a delay, I hope to not receive the torrent not registered error
#sleep $delay;

# download the torrent file to a torrent client monitored directory.
#$bB->download_torrent;


sub print_help {

    say "this is where the help will go"

}
