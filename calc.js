/**
 * 将给定的表达式转化为 tokens 。
 * @param expression 给定的表达式
 * @return Generator<Token>
 */
function* tokenize(expression) {
	const rules = [
		['space', /^\s+/],
		['identifier', /^[A-Za-z_][0-9A-Za-z_]*/],
		['operator', /^[()+*/^-]/]
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
	const identifiers = [];
	const operators = [];

	const precedenceMap = {
		"+": 1, "-": 1,
		"*": 2, "/": 2,
		"^": 3, "(": 0,
	};

	const UNDEFINED = void 22;
	const INVALID_EXPRESSION_ERROR = new Error('Invalid Expression');

	const safePop = stack => {
		const value = stack.pop();

		if (value === UNDEFINED)
			throw INVALID_EXPRESSION_ERROR;

		return value;
	}

	for (const [type, value] of tokens) {
		if (type === 'identifier')
			identifiers.push(value);
		else if (type === 'operator') {
			// 匹配括号
			if (value === '(') {
				operators.push(value);

				continue;
			} else if (value === ')') {
				for (;;) {
					const op = safePop(operators);

					// 遇到左括号停止
					if (op === '(') break;

					const rhs = safePop(identifiers);
					const lhs = safePop(identifiers);

					identifiers.push([op, lhs, rhs]);
				}

				continue;
			}

			// 与之前的运算符的进行比较
			for (let length = 0; length = operators.length;) {
				const op = operators[length - 1];

				// 直到找到比当前运算符优先级小的运算符
				if (precedenceMap[op] < precedenceMap[value]) break;

				safePop(operators);

				const rhs = safePop(identifiers);
				const lhs = safePop(identifiers);

				// 已运算的的结果算是标识符（操作数）
				identifiers.push([op, lhs, rhs]);
			}

			operators.push(value);
		}
	}

	while (operators.length) {
		const op = safePop(operators);
		const rhs = safePop(identifiers);
		const lhs = safePop(identifiers);

		identifiers.push([op, lhs, rhs]);
	}

	let root = safePop(identifiers);

	if (identifiers.length)
		throw INVALID_EXPRESSION_ERROR;

	return root;
}


/*
const stringifyEqual = (x, y) => JSON.stringify(x) === JSON.stringify(y)
stringifyEqual(buildAST(tokenize("a + b * c ^ d - e")), [ "-", [ "+", "a", [ "*", "b", [ "^", "c", "d", ] ] ], "e" ]);
*/
