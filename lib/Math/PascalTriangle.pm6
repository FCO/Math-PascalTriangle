class PascalTriangle {
	my $triangle = [[1]];

	method !generate-line(Int \index-nu where * > 0) {
		my \prev = index-nu - 1;

		self!generate-line(prev) if not $triangle[prev]:exists;

		$triangle[index-nu; 0, index-nu] = 1, 1;
		my \line	= $triangle[index-nu];
		my \prev-line	= $triangle[prev];

		for 1 ..^ index-nu -> $index {
			line[$index] = [+] prev-line[$index - 1, $index]
		}
	}

	method get(Int :$line!, Int :$col! where $line >= *) {
		self!generate-line($line) if not $triangle[$line]:exists;
		$triangle[$line; $col]
	}
}
