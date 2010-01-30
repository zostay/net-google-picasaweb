package Net::Google::PicasaWeb::Test::ListAlbums;
use Test::Able;
use Test::More;

with qw( Net::Google::PicasaWeb::Test::Role::Online );

setup service_login => sub { shift->do_login };

test plan => 'no_plan', happy_login_ok => sub {
    my $self = shift;
    my $service = $self->service;

    my @albums = $service->list_albums;
    
    for my $album (@albums) {
        note("ALBUM ".$album->entry_id." - ".$album->title);
        ok($album->entry_id, 'got an entry ID');
        ok($album->title, 'got a title');
        ok(defined $album->summary, 'got a summary');
        ok($album->author_name, 'got an author_name');
        ok($album->author_uri, 'got an author_uri');
        ok($album->photo, 'got a photo');
        ok($album->bytes_used, 'got bytes used');
        ok($album->number_of_photos, 'got number of photos');
    }
};

1;
