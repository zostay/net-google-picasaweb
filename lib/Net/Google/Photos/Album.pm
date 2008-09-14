use strict;
use warnings;

package Net::Google::Photos::Album;
use Moose;

has service => (
    is => 'rw',
    isa => 'Net::Google::Photos',
    required => 1,
    weaken => 1,
);

has atom_entry => (
    is => 'rw',
    isa => 'XML::Atom::Entry',
);

has title => (
    is => 'rw',
    isa => 'Str',
);

has summary => (
    is => 'rw',
    isa => 'Str',
);

has author_name => (
    is => 'rw',
    isa => 'Str',
);

has author_url => (
    is => 'rw',
    isa => 'Str',
);

sub from_feed {
    my ($class, $service, $entry) = @_;

    my $atom = XML::Atom::Namespace->new( 
        atom => 'http://www.w3.org/2005/atom' 
    );

    my %params = (
        service     => $service,
        atom_entry  => $entry,
        title       => $entry->title,
        summary     => $entry->summary,
    );

    if (my $author = $entry->author) {
        $params{author_name} = $author->name if $author->name;
        $params{author_uri}  = $author->uri  if $author->uri;
    }

    return $class->new(\%params);
}

1;
