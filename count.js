String.prototype.count = function(substring) {
	var i,
		count = 0;
	if (substring)
		while ((i = this.indexOf(substring, i + 1)) !== -1)
			count++;
	else
		count = this.length + 1;
	return count;
}
