def unsigned_right_shift(number, offset, bitwidth=32):
	assert bitwidth > 1
	return (number & ((1 << bitwidth) - 1) \
	  if number < 0 \
	  else number & ((1 << bitwidth) - 1)) >> offset

# (char)-128 >>> 2
unsigned_right_shift(-128, 2, 8)
