use strict;
use warnings;

package Net::Google::PicasaWeb::Comment;
use Moose;

extends 'Net::Google::PicasaWeb::Feed';

=head1 NAME

Net::Google::PicasaWeb::Comment - represents a single Picasa Web comment

=head1 SYNOPSIS

  my @comments = $service->list_comments;
  for my $comment (@comments) {
      print "Title: ", $comment->title, "\n";
      print "Content: ", $photo->content, "\n";
  }

=head1 DESCRIPTION

Represents an individual Picasa Web comment.

=head1 ATTRIBUTES

=head2 title

This is the name of the person that made the comment.

=head2 content

This is the comment that was made.

=cut

has content => (
    is => 'rw',
    isa => 'Str',
);

=head2 author_name

This is the author of the comment.

=head2 author_uri

This is the URL to get to the author's public albums on Picasa Web.

=cut

override from_feed => sub {
    my ($class, $service, $entry) = @_;
    my $self = $class->super($service, $entry);

    $self->content($entry->field('content'));
    return $self;
};

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
