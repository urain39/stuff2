function codegen(root) {
	const stack = [ root ];
	const code = [];

	// DFS
	const parents = [];
	while (stack.length) {
		let { data, left, right } = stack.pop();

		let unsolved = 0;

		if (right) {
			++unsolved;
			stack.push(right);
		}

		if (left) {
			++unsolved;
			stack.push(left);
		}

		if (unsolved) {
			parents.push([unsolved, data]);
		} else {
			// ID
			code.push(data);

			for (; parents.length ;) {
				const context = parents[parents.length - 1];

				[ unsolved ] = context;
				--unsolved;

				if (unsolved !== 0) {
					context[0] = unsolved;

					break;
				}

				parents.pop();
				[ , data ] = context;

				// OP
				code.push(data);
			}
		}
	}

	return code;
}

let root = {
	data: "+",
	left: {
		data: "*",
		left: {
			data: "a",
		},
		right:{
			data: "b",
		},
	},
	right: {
		data: "+",
		left: {
			data: "c"
		},
		right: {
			data: "d"
		}
	}
};

codegen(root);
