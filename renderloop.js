;(function() {
	const delayBase = 16;

	function setTimer(callback, delayFactor) {
		setTimeout(function() {
			callback();
		}, delayFactor * delayBase);
	}

	(function renderLoop() {
		while (true) {
			if (inst === "int") {
				setTimer(renderLoop, delay);
				break;
			}
		}
	})();
})();
