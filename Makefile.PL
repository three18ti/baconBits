use inc::Module::Install;

name     'baconBits';
all_from 'lib/baconBits.pm';
author   q{three18ti <three18ti@gmail.com>};
license  'perl';

build_requires 'Test::More';

requires 'Getopt::Long' => '2.38';
requires 'Config::Any' => '0.23';
requires 'Moose' => '2.0403';
requires 'YAML::XS' => '0.38';

requires_external_bin 'ctorrent';
requires_external_bin 'pythonbits';

auto_install;

WriteAll;

