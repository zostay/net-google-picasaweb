use inc::Module::Install;

name     'Net-Google-Photos';
all_from 'lib/Net/Google/Photos.pm';
author   'Andrew Sterling Hanenkamp <hanenkamp@cpan.org>';

build_requires 'Test::More';

requires 'LWP::UserAgent';
requires 'Net::Google::AuthSub';
requires 'URI';
requires 'XML::Twig';

auto_install;

WriteAll;

