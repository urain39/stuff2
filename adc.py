def adc(a, b, c):
	# a + b
	t0 = a ^ b
	# 判断是否进位
	c0 = a & b
	# (a + b) + c
	t1 = t0 ^ c
	# 判断是否进位
	c1 = t0 & c
	# 最终进位判断
	c2 = c0 | c1
	return t1, c2
