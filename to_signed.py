def to_signed(number, bitwidth):
	# Should we handle negative value?
	# number = to_unsigned(number, bitwidth)
	assert number >= 0
	assert bitwidth > 1
	max_value = (1 << bitwidth) - 1
	assert number <= max_value
	if number & (1 << bitwidth - 1):
		number = -(~(number - 1) & ((1 << bitwidth) - 1))
	return number

# (short)65535
to_signed(65535, 16)
