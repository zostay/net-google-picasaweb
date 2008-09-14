use inc::Module::Install;

name     'Net-Google-Photos';
all_from 'lib/Net/Google/Photos.pm';
author   'Andrew Sterling Hanenkamp <hanenkamp@cpan.org>';

build_requires 'Test::More';

requires 'Net::Google::AuthSub';

auto_install;

WriteAll;

