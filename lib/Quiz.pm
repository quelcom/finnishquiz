#!/usr/bin/perl
package Quiz;
use strict;
use warnings;
use utf8;

use Encode;
use DBI;
use POSIX qw(ceil);
use FindBin;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;

@ISA = qw(Exporter AutoLoader);

@EXPORT = qw(
  dbinit
  check_word
  get_hint_word
  get_n_random_records
);

my $dbh = dbinit();

=head2
    Creates the database handle
    Params: none
    Returns: database handle
=cut
sub dbinit {
    my $dbh = DBI->connect("dbi:SQLite:dbname=$FindBin::Bin/../var/words.db")
        or die "Could not connect to DB!";
    return $dbh;
}

=head2
    Get multiple random records from db
    Params: number of records to retreive
    Returns: array ref
=cut
sub get_n_random_records {
    my $num = shift // 1;    # gets 1 if no parameters
    my ( $from, $to ) = @_;

    my $sql = "SELECT * FROM PARAULES ";
    $sql .= "WHERE $from != '' " if $from;
    $sql .= "AND $to != '' "     if $to;
    $sql .= "ORDER BY random() LIMIT ?";

    my $sth = $dbh->prepare($sql);
    $sth->execute($num);

    my @data = ();
    while ( my $record = $sth->fetchrow_hashref ) {
        push( @data, $record );
    }

    return (wantarray) ? @data : $data[0];
}

=head2
    Checks if a word is correct
    Params:
        submitted answer
        correct definition
    Returns:
        true -> matches
        false -> doesn't match
=cut
sub check_word {
    my ( $user_word, $correct_word ) = @_;
    return grep { $user_word eq $_ } split '/', $correct_word;
}

=head2
    Returns an easy version of the word
    Params: word
    Return: word
=cut
sub get_hint_word {
    my $word = decode_utf8(shift);

    my $length_of_word = length $word;

    # 1-3 chars => 1; 4-6 chars => 2; 7-9 chars => 3...
    my $chars_to_autocomplete = ceil( $length_of_word / 3 );

    my @random_positions = ();
    while ( scalar(@random_positions) < $chars_to_autocomplete ) {
        my $position = int( rand($length_of_word) );
        push( @random_positions, $position )
          unless $position ~~ @random_positions;
    }

    my $easy_word = "_" x $length_of_word;
    foreach my $rand_pos (@random_positions) {
        substr( $easy_word, $rand_pos, 1 ) = substr( $word, $rand_pos, 1 );
    }

    return encode_utf8($easy_word);
}

1;
