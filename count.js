String.prototype.count = function count(substring) {
	let count = 0;

	if (substring) {
		const length = substring.length;

		let from = -length;

		while ((from = this.indexOf(substring, from + length)) !== -1) count++;
	} else
		count = this.length + 1;

	return count;
}
