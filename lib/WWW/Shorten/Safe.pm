# $Id: Safe.pm 106 2009-05-27 21:06:26Z jsobrier $
# $Author: jsobrier $
# $Date: 2009-05-27 02:36:26 +0530 (Wed, 27 My 2009) $
# Author: <a href=mailto:jsobrier@safe.mn>Julien Sobrier</a>
################################################################################################################################
package WWW::Shorten::Safe;

use warnings;
use strict;
use Carp;

use base qw( WWW::Shorten::generic Exporter );

require Exporter;

our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(new version);

my @ISA = qw(Exporter);

use vars qw( @ISA @EXPORT );


=head1 NAME

WWW::Shorten::Safe - Interface to shortening URLs using L<http://safe.mn/>

=head1 VERSION

$Revision: 100 $

=cut

BEGIN {
    our $VERSION = do { my @r = (q$Revision: 1.06 $ =~ /\d+/g); sprintf "%1d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker
    $WWW::Shorten::Safe::VERBOSITY = 2;
}

# ------------------------------------------------------------


=head1 SYNOPSIS

WWW::Shorten::Safe provides an easy interface for shortening URLs using http://safe.mn/. 


    use WWW::Shorten::Safe;

    my $url = "http://www.example.com";

    my $tmp = makeashorterlink($url);
    my $tmp1 = makealongerlink($tmp);

or

    use WWW::Shorten::Safe;

    my $url = "http://www.example.com";
    my $safe = WWW::Shorten::Safe->new(URL   => $url);

    $safe->shorten(URL => $url);
    print "shortened URL is $safe->{safeurl}\n";

    $safe->expand(URL => $safe->{safeurl});
    print "expanded/original URL is $safe->{longurl}\n";


=head1 FUNCTIONS

=head2 new

Create a new safe.mn object.

my $safe = WWW::Shorten::Safe->new(URL  => "http://www.example.com/this_is_one_example.html");

=cut

sub new {
    my ($class) = shift;
    my %args    = @_;
    $args{source} ||= "perlteknatussafe"; 
    my $safe;
    $safe->{browser}   = LWP::UserAgent->new(agent => $args{source});
    my ($self) = $safe;
    bless $self, $class;
}


=head2 makeashorterlink

The function C<makeashorterlink> will call the safe.mn API site passing it
your long URL and will return the shorter safe.mn version.


=cut

sub makeashorterlink #($;%)
{
    my $url = shift or croak('No URL passed to makeashorterlink');
    my $ua = __PACKAGE__->ua();
    my $safe;
    my $safeurl = "http://safe.mn/api/?format=text&url=" . $url;
    $safe->{response} = $ua->get($safeurl);
    $safe->{safeurl} = $safe->{response}->{_content};
    $safe->{safeurl} =~ s/\s//mg;
    return unless $safe->{response}->is_success;
    return $safe->{safeurl};
}

=head2 makealongerlink

The function C<makealongerlink> does the reverse. C<makealongerlink>
will accept as an argument the full safe.mn URL.

If anything goes wrong, then the function will return C<undef>.

=cut

sub makealongerlink #($,%)
{
    my $url = shift or croak('No shortened safe.mn URL passed to makealongerlink');
    my $ua = __PACKAGE__->ua();
    my $safe;
    my @foo = split(/\//, $url);
    my $safeurl = URI->new('http://safe.mn/api/?format=text&short_url=' . $url);
    $safe->{response} = $ua->get($safeurl);
    $safe->{longurl} = $safe->{response}->{_content};
    $safe->{longurl} =~ s/\s//mg;
    return undef unless $safe->{response}->is_success;
    return $safe->{longurl};
}

=head2 shorten

Shorten a URL using http://safe.mn/.  Calling the shorten method will return the shortened URL but will also store it in safe.mn object until the next call is made.

    my $url = "http://www.example.com";
    my $shortstuff = $safe->shorten(URL => $url);

    print "safeurl is " . $safe->{safeurl} . "\n";
or
    print "safeurl is $shortstuff\n";

=cut


sub shorten {
    my $self  = shift;
    my %args  = @_;
    if (!defined $args{URL}) {
        croak("URL is required.\n");
        return -1;
    }
    $self->{short}   = "http://safe.mn/api/?format=text&url=" . $args{URL};
    $self->{response} = $self->{browser}->get($self->{short});
    return undef unless $self->{response}->is_success;;
    $self->{safeurl} = $self->{response}->{_content};
    $self->{safeurl} =~ s/\s//mg;
    return $self->{safeurl};
}

=head2 expand

Expands a shortened safe.mn URL to the original long URL.

=cut
sub expand {
    my $self  = shift;
    my %args  = @_;
    if (!defined $args{URL}) {
        croak("URL is required.\n");
        return -1;
    }
    my @foo = split(/\//, $args{URL});
    $self->{short}   = "http://safe.mn/api/?format=text&short_url=" . $args{URL};
    $self->{response} = $self->{browser}->get($self->{short});
    return undef unless $self->{response}->is_success;;
    $self->{longurl} = $self->{response}->{_content};
    $self->{longurl} =~ s/\s//mg;
    return $self->{longurl};
}

=head2 version

Gets the module version number

=cut
sub version {
    my $self     = shift;
    my($version) = shift;# not sure why $version isn't being set. need to look at it
    warn "Version $version is later then $WWW::Shorten::Safe::VERSION. It may not be supported" if (defined ($version) && ($version > $WWW::Shorten::Safe::VERSION));
    return $WWW::Shorten::Dafe::VERSION;
}#version


=head1 AUTHOR

Julien Sobrier, C<< <jsobrier at safe.mn> >>

=head1 BUGS

Please report any bugs or feature requests to C<jsobrier at safe.mn>.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Shorten::Safe


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Shorten-Safe>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Shorten-Safe>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Shorten-Safe>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Shorten-Safe/>

=back


=head1 ACKNOWLEDGEMENTS

=over

=item Dave Cross for WWW::Shorten.
.

=back

=head1 COPYRIGHT & LICENSE

=over

=item Copyright (c) 2009 Julien Sobrier, All Rights Reserved L<http://safe.mn/>.


=back

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=head1 SEE ALSO

L<perl>, L<WWW::Shorten>, L<http://safe.mn/tools/#api>.

=cut

1; # End of WWW::Shorten::Safe
