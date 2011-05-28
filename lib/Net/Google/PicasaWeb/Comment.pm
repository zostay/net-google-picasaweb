package Net::Google::PicasaWeb::Comment;
use Moose;

# ABSTRACT: represents a single Picasa Web comment

extends 'Net::Google::PicasaWeb::Feed';

=head1 SYNOPSIS

  my @comments = $service->list_comments;
  for my $comment (@comments) {
      print "Title: ", $comment->title, "\n";
      print "Content: ", $photo->content, "\n";
  }

=head1 DESCRIPTION

Represents an individual Picasa Web comment. This class extends L<Net::Google::PicasaWeb::Feed>.

=head1 ATTRIBUTES

=head2 url

The URL used to get information about the object. See L<Net::Google::PicasaWeb::Feed/url>.

=head2 title

This is the name of the person that made the comment. See L<Net::Google::PicasaWeb:::Feed/title>.

=head2 content

This is the comment that was made.

=cut

has content => (
    is          => 'rw',
    isa         => 'Str',
);

=head2 author_name

This is the author of the comment. See L<Net::Google::PicasaWeb::Feed/author_name>.

=head2 author_uri

This is the URL to get to the author's public albums on Picasa Web. See L<Net::Google::PicasaWeb::Feed/author_uri>.

=cut

override from_feed => sub {
    my ($class, $service, $entry) = @_;
    my $self = $class->super($service, $entry);

    $self->content($entry->field('content'));
    return $self;
};

=head2 entry_id

This is the unique ID for the comment. See L<Net::Google::PicasaWeb::Feed/entry_id>.

=cut

1;
