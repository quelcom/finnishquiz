use strict;
use warnings;
use utf8;
use Encode;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More tests => 21;

use_ok("Quiz");

is(3,3, 'is basic usage: 3 is 3 :)');
isnt(4,3, 'isnt basic usage: 4 is not 3');

# Basic comparations
# Return value of check_word => 1 correct, 0 incorrect
is( check_word( "foo",      "foo"           ), 1, 'equal word'          );
is( check_word( "árbol",    "árbol/madera"  ), 1, 'árbol is matched'    );
is( check_word( "madera",   "árbol/madera"  ), 1, 'madera is matched'   );
is( check_word( "árbol",    "foo"           ), 0, 'wrong match'         );

# DB operations
# Get a handle
my $dbh = dbinit();
isnt($dbh, undef, 'databse handle not undef');

my @data = get_n_random_records(3);
is( scalar @data, 3, 'right number of elements' );
like( $data[1]->{id}, qr/\d+/, 'id is a number in $data[1]' );
isnt( $data[1]->{spanish}, undef, 'spanish not empty in $data[1]' );
is( $data[1]->{chiquistan}, undef, 'chiquistan does not exist in $data[1]' );

my @other_data = get_n_random_records();    # 1 by defualt
is( scalar @other_data,
    1, 'one record is the default for get_n_random_records' );
like( $other_data[0]->{id}, qr/\d+/, 'id is a number in $another_data[0]' );
is( $other_data[1]->{id}, undef, '$other_data[1] does not exist' );

# Hint words
is( length get_hint_word("patata"),
    6, 'hint word has as many characters as the original' );
is( length get_hint_word("kuu"),
    3, 'hint word has as many characters as the original' );

# Accents
is( length decode_utf8( get_hint_word("ñañañá") ),
    6, "ñañañá length is correct; 6" );

like( get_hint_word("kuu"), qr/(k|_)(u|_)(\u|_)/, 'k__ or _u_ or __u' );
like( get_hint_word("casa"), qr/(a|c|s|_){4}/, 'only those chars are allowed' );
like( get_hint_word("aaaaaaaaaa"), qr/(a|_){10}/, 'only a or _ is allowed' );

