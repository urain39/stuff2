
/**
 * @param string 给定的字符串
 * @param pattern 查找的字符串
 */
function BFSearch(string, pattern) {
	const sl = string.length;
	const pl = pattern.length;

	let curr, i, j;
	for (curr = i = j = 0; i < sl && j < pl;) {
		if (string.charAt(i) === pattern.charAt(j)) {
			i++;
			j++;
		} else {
			i = ++curr; // 回退
			j = 0;
		}
	}

	return j === pl ? curr : -1;
}
