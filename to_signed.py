def to_signed(number, bitwidth=32):
	assert number >= 0
	assert bitwidth > 1
	# 网上的另一种方法，如下所示：
	# ```py
	# return number & ((1 << bitwidth) - 1) \
	#   if number < (1 << bitwidth - 1) \
	#   else (number & ((1 << bitwidth) - 1)) - (1 << bitwidth)
	# ```
	# 但通用性不行（位宽溢出），此外好像多了一些步骤
	#
	# ----------------------------------------------------------
	#
	# 计算过程：
	#
	# 1. 在忽略高位的情况下将负数还原
	# 2. 使用掩码将高位去掉以得到原值
	# 3. 最后再将原值转换为正确的数值
	#
	# 注：你可能好奇高位的 1 去哪了？它
	# 实际上在第一次取负时就被转换成 0 了
	#
	# 注2：取负时高位不会影响结果，所以
	# number 可以不用先掩码
	#
	# 示例过程：
	# 11 2bit -1
	# 011 储存在 3bit 中
	# 100 取反
	# 101 加1
	# 001 掩码
	# 110 再取反
	# 111 再加1
	return -(-number & ((1 << bitwidth) - 1)) \
	  if number & (1 << bitwidth - 1) \
	  else number & ((1 << bitwidth) - 1)

# (short)65535
print(to_signed(65535, 16))
