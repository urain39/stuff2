#include <stdio.h>

#include "endian.h"

int main()
{
	unsigned long n = 0x1234567890123456;
	printf(
		"Is_Big_Endian: %d\n"
		"Is_Little_Endian: %d\n"
		"Swap_Bytes64(0x%lx): 0x%lx\n",
		is_big_endian(),
		is_little_endian(),
		n, SWAP_BYTES64(n));
}
