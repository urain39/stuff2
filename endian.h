#define SWAP_BYTES(n) ( \
	(n << 8) | (n >> 8) \
)

#define SWAP_BYTES32(n) ( \
	(SWAP_BYTES(n << 16)) | (SWAP_BYTES(n >> 16)) \
)

#define SWAP_BYTES64(n) ( \
	(SWAP_BYTES32(n << 32)) | (SWAP_BYTES32(n >> 32)) \
)

/**
 * Returns true if running on a big-endian machine.
 */
int is_big_endian();

/**
 * Returns true if running on a little-endian machine.
 */
int is_little_endian();
