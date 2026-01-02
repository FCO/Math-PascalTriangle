[![Actions Status](https://github.com/FCO/Math-PascalTriangle/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/Math-PascalTriangle/actions)

NAME
====

Math::PascalTriangle — Pascal’s triangle binomial coefficients

SYNOPSIS
========

```raku
use Math::PascalTriangle;
say Math::PascalTriangle.get(:line(4), :col(2)); # 6

# build a row (0-based indexing)
my $n = 6;
say (0..$n).map({ Math::PascalTriangle.get(:line($n), :col($_)) }).join(' ');
```

OVERVIEW
========

Pascal’s triangle is a triangular arrangement of numbers where each entry is a binomial coefficient. The outer edges are `1`. Interior values are the sum of the two entries directly above: `T(n, k) = T(n-1, k) + T(n-1, k-1)`.

  * Symmetry: `T(n, k) = T(n, n-k)`.

  * Polynomial coefficients: row `n` gives coefficients of `(a + b)^n`.

  * Combinatorics: `T(n, k) = C(n, k)` counts ways to choose `k` elements from `n`.

Indexing in this module is 0-based: the first row/line is `line = 0`, and the first column is `col = 0`. Therefore `get(:line(n), :col(k))` returns `C(n, k)`.

USAGE
=====

This module exposes a single class method `get` to retrieve entries.

  * Call as `Math::PascalTriangle.get(:line($n), :col($k))`.

  * Valid inputs: `UInt` values with `0 <= k <= n`.

  * Returns big integers when values grow large.

  * Throws when `col > line` (no triangle entry).

DESCRIPTION
===========

Internally, values are computed via the recursive identity `C(n, k) = C(n-1, k) + C(n-1, k-1)` and memoized. A simple LRU policy bounds the cache to 9999 entries to avoid unbounded memory growth.

METHODS
=======

method `get(UInt:D() :$line!, UInt:D() :$col!)` Returns the binomial coefficient `C(line, col)`.
------------------------------------------------------------------------------------------------

  * Base cases: `col == 0` and `col == line` return `1`.

  * Recursive case: for `0 < col < line`, computes `C(line - 1, col) + C(line - 1, col - 1)`.

  * Error case: when `col > line`, no candidate matches and an exception is thrown (see `t/02-triangle.t`).

CACHING
=======

Results are cached in `%cache` keyed by the capture `($line, $col)`. Each access bumps a count in `%LRU`. When `%LRU.elems` exceeds `9999`, the least-recently used key (lowest count) is evicted from both `%LRU` and `%cache`.

EXAMPLES
========

Single entries
--------------

```raku
Math::PascalTriangle.get(:line(9), :col(4))   # 126
Math::PascalTriangle.get(:line(99), :col(49)) # 50445672272782096667406248628

# Generate a row
auto $row = 9;
(0..$row).map({ Math::PascalTriangle.get(:line($row), :col($_)) }).say;

# Symmetry example (true)
Math::PascalTriangle.get(:line(9), :col(2)) == Math::PascalTriangle.get(:line(9), :col(7))
```

AUTHOR
======

See `META6.json` for authorship information.

LICENSE
=======

Same license as this distribution; see `META6.json`.

