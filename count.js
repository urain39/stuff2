String.prototype.count = function(substring) {
	var i = -1,
		count = 0;
	if (substring)
		while ((i = this.indexOf(substring, i + substring.length)) !== -1)
			count++;
	else
		count = this.length + 1;
	return count;
}
