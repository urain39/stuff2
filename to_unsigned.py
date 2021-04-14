def to_unsigned(number, bitwidth=32):
	assert bitwidth > 1
	max_value = (1 << bitwidth - 1) - 1
	if number < 0:
		number = -number
		assert number <= max_value + 1
		number = (~number & ((1 << bitwidth) - 1)) + 1
	else:
		assert number <= max_value
	return number

# (unsigned char)-1
to_unsigned(-1, 8)
