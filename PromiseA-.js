/**
 * Implemented by urain39@qq.com
 */

const ST_PENDING = 0;
const ST_FULFILLED = 1;
const ST_REJECTED = 2;

const VAL_UNDEFINED = void 0;


function call(fn, ...args) {
	let error = null,
		result = null;

	try {
		result = fn(...args);
	} catch (error_) {
		error = error_;
	}

	return [error, result];
}


export class Promise {
	static resolve(value) {
		if (value instanceof Promise) {
			return value;
		}

		return new Promise(function (resolve) {
			resolve(value);
		});
	}

	static reject(reason) {
		return new Promise(function (_resolve, reject) {
			reject(reason);
		});
	}

	constructor(executor) {
		this.state = ST_PENDING;
		this.value = VAL_UNDEFINED;
		this.reason = VAL_UNDEFINED;
		this.onChanged = function () {};

		const promise = this;

		const [error] = call(executor, function (value) {
			promise.value = value;
			promise.state = ST_FULFILLED;
			promise.onChanged();
		}, function (reason) {
			promise.reason = reason;
			promise.state = ST_REJECTED;
			promise.onChanged();
		});

		if (error) {
			promise.reason = error;
			promise.onChanged();
		}
	}

	then(onFulfilled, onRejected) {		
		let reason, state,
			error, result;

		const promise = this;

		state = promise.state;
		if (state === ST_FULFILLED) {
			[error, result] = call(onFulfilled, promise.value);

			if (error) {
				return Promise.reject(error);
			}

			return Promise.resolve(result);
		} else if (state === ST_REJECTED) {
			reason = promise.reason;

			if (onRejected) {
				[error] = call(onRejected, reason);

				if (error) {
					return Promise.reject(error);
				}

				// Make sure returns *thenable*
				return Promise.resolve();
			}

			return Promise.reject(reason);
		}

		// ST_PENDING
		return new Promise(function (resolve, reject) {
			promise.onChanged = function () {
				state = promise.state;

				if (state === ST_FULFILLED) {
					[error, result] = call(onFulfilled, promise.value);

					if (error) {
						return Promise.reject(error);
					}

					// Apply handlers
					return Promise.resolve(result).then(resolve, reject);
				} else if (state === ST_REJECTED) {
					reason = promise.reason;

					if (onRejected) {
						[error] = call(onRejected, reason);

						if (error) {
							return Promise.reject(error);
						}

						return Promise.resolve();
					}

					return Promise.reject(reason);
				}
			};
		});
	}

	catch(onRejected) {
		const promise = this;

		return promise.then(function () {}, onRejected);
	}
}
