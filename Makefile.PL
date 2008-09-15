use inc::Module::Install;

name     'Net-Google-PicasaWeb';
all_from 'lib/Net/Google/PicasaWeb.pm';
author   'Andrew Sterling Hanenkamp <hanenkamp@cpan.org>';

build_requires 'Test::More';
build_requires 'Test::Mock::LWP';

requires 'LWP::UserAgent';
requires 'Net::Google::AuthSub';
requires 'URI';
requires 'XML::Twig';

install_script 'script/picasa-get';

auto_install;

WriteAll;

