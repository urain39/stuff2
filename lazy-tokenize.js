/**
 * 将给定的表达式转化为 tokens
 * @param expression 给定的表达式
 * @return Generator<Token>
 */
function* tokenize(expression) {
	const rules = [
		['space', /^\s+/],
		['number', /^\d+/],
		['operator', /^[+*/-]/]
	];

	let current = expression;

	for (; current ;) {
		let matched = null;

		for (const [ type, rule ] of rules) {
			matched = current.match(rule);

			if (matched) {
				const [ result ] = matched;
				current = current.slice(result.length);

				yield [type, result];

				break;
			}
		}

		if (!matched)
			throw new Error(`Unexpected char '${current[0]}'`);
	}
}
