/**
 * A lib to generate dirty version suffix.
 */

var { version } = require('../package');


function toShortString(num) {
	var mod,
		str = '',
		base = '0'.charCodeAt(0),
		base2 = 'a'.charCodeAt(0);

	num = Number(num);

	while (num > 0) {
		mod = num % 32;

		if (mod === 0)
			mod = 32;

		str += mod < 10 ?
			String.fromCharCode(base + mod)
		:
			String.fromCharCode(base2 + mod - 10)
		;

		num = (num - mod) / 32;
	}

	return str.split('').reverse().join('');
}

exports.getDirtyVersion = function() {
	return `${version}-${toShortString(Date.now())}`;
}
