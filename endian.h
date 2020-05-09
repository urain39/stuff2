#define SWAP_BYTES(n) ( \
	((n & 0xff) << 8) | ((n & 0xff00) >> 8) \
)

#define SWAP_BYTES32(n) ( \
	(SWAP_BYTES(n & 0xffff) << 16) | (SWAP_BYTES((n & 0xffff0000) >> 16)) \
)

#define SWAP_BYTES64(n) ( \
	(SWAP_BYTES32(n & 0xffffffff) << 32) | (SWAP_BYTES32((n & 0xffffffff00000000) >> 32)) \
)

/**
 * Returns true if running on a big-endian machine.
 */
int is_big_endian();

/**
 * Returns true if running on a little-endian machine.
 */
int is_little_endian();
