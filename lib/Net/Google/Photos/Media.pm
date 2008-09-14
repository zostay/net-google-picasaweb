use strict;
use warnings;

package Net::Google::Photos::Media;
use Moose;

extends 'Net::Google::Photos::Base';

has title => (
    is => 'rw',
    isa => 'Str',
);

has description => (
    is => 'rw',
    isa => 'Str',
);

has content => (
    is => 'rw',
    isa => 'Net::Google::Photos::Media::Content',
);

has thumbnails => (
    is => 'rw',
    isa => 'ArrayRef[Net::Google::Photos::Media::Thumbnail]',
);

sub from_feed {
    my ($class, $service, $media_group) = @_;

    my $content = $media_group->first_child('media:content');

    my %params = (
        service     => $service,
        twig        => $media_group,
        title       => $media_group->field('media:title'),
        description => $media_group->field('media:description'),
        content     => Net::Google::Photos::Media::Content->new(
            url       => $content->att('url'),
            mime_type => $content->att('type'),
            medium    => $content->att('medium'),
        ),
        thumbnails  => [
            map { 
                Net::Google::Photos::Media::Thumbnail->new(
                    url    => $_->att('url'),
                    width  => $_->att('width'),
                    height => $_->att('height'),
                )
            } $media_group->children('media:thumbnail')
        ],
    );       
    
    return $class->new(\%params);
}

sub fetch_content {
    my $self = shift;
    return $self->_fetch('content', @_);
}

sub fetch_thumbnail {
    my $self = shift;
    return $self->_fetch('thumbnail', @_);
}

sub _fetch {
    my ($self, $which, %params) = @_;
    my $url = $self->$which->url;

    my %header;
    $header{':content_file'} = $params{file} if $params{file};

    my $response = $self->service->user_agent->get($url, %header);

    if ($response->is_success) {
        return $response->content;
    }
    else {
        croak $response->status_line;
    }
}

package Net::Google::Photos::Media::Content;
use Moose;

has url => (
    is => 'rw',
    isa => 'Str',
);

has mime_type => (
    is => 'rw',
    isa => 'Str',
);

has medium => (
    is => 'rw',
    isa => 'Str',
);

package Net::Google::Photos::Media::Thumbnail;
use Moose;

has url => (
    is => 'rw',
    isa => 'Str',
);

has width => (
    is => 'rw',
    isa => 'Int',
);

has height => (
    is => 'rw',
    isa => 'Int',
);

1;
