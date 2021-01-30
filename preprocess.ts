function _preprocess(value: string): any {
	const l = value.length;

	if (l > 0 && l <= 20) {
		const n = Number(value);

		if (n || n === 0)
			return n;

		if (value === 'true')
			return true;

		if (value === 'false')
			return false;

		if (value === 'null')
			return null;
	}

	return value;
}

export function preprocess(object: any): any {
	let value: any,
		type: string;

	for (const key in object) {
		value = object[key];
		type = typeof value;

		if (type === 'string') {
			object[key] = _preprocess(value);
		} else if (type === 'object') {
			preprocess(value);
		}
	}

	return object;
}
