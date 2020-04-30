def to_unsigned(number, bitwidth=32):
	assert bitwidth > 1
	# 注：网上还有一种方法，如下所示：
	# ```py
	# ((1 << bitwidth) + number) & ((1 << bitwidth) - 1)
	# ```
	# 它是使用了补码的定义进行计算的。原版没有后面的按位与，我加上
	# 是为了防止数值溢出。
	return number & ((1 << bitwidth) - 1)

# (unsigned char)-1
print(to_unsigned(-1, 8))
