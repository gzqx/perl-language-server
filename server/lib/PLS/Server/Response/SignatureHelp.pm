package PLS::Server::Response::SignatureHelp;

use strict;
use warnings;

use parent q(PLS::Server::Response);

use PLS::Parser::Document;

=head1 NAME

PLS::Server::Response::SignatureHelp

=head1 DESCRIPTION

This is a message from the server to the client with information about the
parameters of the current function.

=cut

sub new
{
    my ($class, $request) = @_;

    my $self = bless {
                      id     => $request->{id},
                      result => undef
                     }, $class;

    my ($line, $character) = @{$request->{params}{position}}{qw(line character)};
    my $document = PLS::Parser::Document->new(uri => $request->{params}{textDocument}{uri}, line => $line);
    return $self if (ref $document ne 'PLS::Parser::Document');

    my $list             = $document->find_current_list($line, $character);
    my $results          = $document->go_to_definition_of_closest_subroutine($list, $line, $character);
    my @signatures       = map { $_->{signature} } @{$results};
    my $active_parameter = $document->get_list_index($list, $request->{params}{position}{line}, $request->{params}{position}{character});

    $self->{result} = {signatures => \@signatures, activeParameter => $active_parameter} if (scalar @signatures);

    return $self;
} ## end sub new

1;
