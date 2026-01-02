=begin pod
=head1 NAME

Math::PascalTriangle — Pascal’s triangle binomial coefficients

=head1 SYNOPSIS

=begin code :lang<raku>

use Math::PascalTriangle;
say Math::PascalTriangle.get(:line(4), :col(2)); # 6

# build a row (0-based indexing)
my $n = 6;
say (0..$n).map({ Math::PascalTriangle.get(:line($n), :col($_)) }).join(' ');

=end code

=head1 OVERVIEW

Pascal’s triangle is a triangular arrangement of numbers where each entry is a
binomial coefficient. The outer edges are C<1>. Interior values are the sum of
the two entries directly above: C<T(n, k) = T(n-1, k) + T(n-1, k-1)>.

=item Symmetry: C<T(n, k) = T(n, n-k)>.
=item Polynomial coefficients: row `n` gives coefficients of C<(a + b)^n>.
=item Combinatorics: C<T(n, k) = C(n, k)> counts ways to choose C<k> elements from C<n>.

Indexing in this module is 0-based: the first row/line is C<line = 0>, and the
first column is C<col = 0>. Therefore C<get(:line(n), :col(k))> returns C<C(n, k)>.

=head1 USAGE

This module exposes a single class method `get` to retrieve entries.

=item Call as C<Math::PascalTriangle.get(:line($n), :col($k))>.
=item Valid inputs: C<UInt> values with C<<0 <= k <= n>>.
=item Returns big integers when values grow large.
=item Throws when C<<col > line>> (no triangle entry).

=head1 DESCRIPTION

Internally, values are computed via the recursive identity
C<C(n, k) = C(n-1, k) + C(n-1, k-1)> and memoized. A simple LRU policy bounds
the cache to 9999 entries to avoid unbounded memory growth.

=head1 METHODS

=head2 method C<get(UInt:D() :$line!, UInt:D() :$col!)>
Returns the binomial coefficient C<C(line, col)>.

=item Base cases: C<col == 0> and C<col == line> return C<1>.
=item Recursive case: for C<<0 < col < line>>, computes C<C(line - 1, col) + C(line - 1, col - 1)>.
=item Error case: when C<<col > line>>, no candidate matches and an exception is thrown (see C<t/02-triangle.t>).

=head1 CACHING

Results are cached in C<%cache> keyed by the capture C<($line, $col)>. Each access
bumps a count in C<%LRU>. When C<%LRU.elems> exceeds C<9999>, the least-recently
used key (lowest count) is evicted from both C<%LRU> and C<%cache>.

=head1 EXAMPLES

=head2 Single entries

=begin code :lang<raku>
Math::PascalTriangle.get(:line(9), :col(4))   # 126
Math::PascalTriangle.get(:line(99), :col(49)) # 50445672272782096667406248628

# Generate a row
auto $row = 9;
(0..$row).map({ Math::PascalTriangle.get(:line($row), :col($_)) }).say;

# Symmetry example (true)
Math::PascalTriangle.get(:line(9), :col(2)) == Math::PascalTriangle.get(:line(9), :col(7))

=end code

=head1 AUTHOR

See C<META6.json> for authorship information.

=head1 LICENSE

Same license as this distribution; see C<META6.json>.

=end pod

class Math::PascalTriangle {
	my %cache{Capture:D};
	my %LRU{Capture:D} = Bag.new;

	proto method get(UInt:D() :$line!, UInt:D() :$col!) {{*}}

	multi method get(:$line!, :$col! where * == 0) {1}

	multi method get(:$line!, :$col! where $line == *) {1}

	multi method get(:$line!, :$col! where $line > *) {
		%LRU{\($line<>, $col<>)}++;
		if %LRU.elems > 9999 {
			my \min = %LRU.sort(*.value)>>.key.first;
			%LRU{min}:delete;
			%cache{min}:delete;
		}
		return $_ with %cache{\($line<>, $col<>)};
		%cache{\($line<>, $col<>)} = $.get(:line($line - 1), :$col) + $.get(:line($line - 1), :col($col - 1))
	}
}
