def to_unsigned(number, bitwidth=32):
	assert bitwidth > 1
	return number & ((1 << bitwidth) - 1)

# (unsigned char)-1
print(to_unsigned(-1, 8))
