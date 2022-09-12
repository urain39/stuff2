def to_signed(number, bitwidth=32):
	assert number >= 0
	assert bitwidth > 1
	# 1. 在忽略高位的情况下将负数还原
	# 2. 使用掩码将高位去掉以得到原值
	# 3. 最后再将原值转换为正确的数值
	#
	# 注：你可能好奇高位的 1 去哪了？它
	# 实际上在第一次翻转时就被转换成 0 了
	return -(-number & ((1 << bitwidth) - 1)) \
	  if number & (1 << bitwidth - 1) \
	  else number & ((1 << bitwidth) - 1)

# (short)65535
print(to_signed(65535, 16))
