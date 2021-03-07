/**
 * 将给定的表达式转化为 tokens 。
 * @param expression 给定的表达式
 * @return Generator<Token>
 */
function* tokenize(expression, skipSpace) {
	const rules = [
		['space', /^\s+/],
		['number', /^-?\d+/],
		['operator', /^[()^+*/-]/]
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

/**
 * 将给定的 tokens 构建为 AST。
 * @param tokens Generator<Token>
 * @return ExprAST
 */
function buildAST(tokens) {
	const numbers = [];
	const operators = [];

	const precedenceMap = {
		"+": 1, "-": 1,
		"*": 2, "/": 2,
		"^": 3,
	};

	for (const [type, value] of tokens) {
		if (type === 'number')
			numbers.push(Number(value));
		else if (type === 'operator') {
			if (operators.length) {
				const op = operators[operators.length - 1];

				if (precedenceMap[op] >= precedenceMap[value]) {
					operators.pop();

					const rhs = numbers.pop();
					const lhs = numbers.pop();

					// 已运算的的结果算是操作数
					numbers.push([op, lhs, rhs]);
				}
			}

			operators.push(value);
		}
	}

	while (operators.length) {
		const op = operators.pop();
		const rhs = numbers.pop();
		const lhs = numbers.pop();

		numbers.push([op, lhs, rhs]);
	}

	if (numbers.length !== 1) {
		throw new SyntaxError('Invalid Expression');
	}

	return numbers[0];
}
