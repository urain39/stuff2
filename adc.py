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

def adc_2bit(a, b, c):
	# 低位计算
	t0, c0 = adc(a & 1, b & 1, c)
	# 高位计算
	t1, c1 = adc(a >> 1, b >> 1, c0)
	# 合并结果
	t2 = (t1 << 1) | t0
	return t2, c1

def adc_4bit(a, b, c):
	# 低2位计算
	t0, c0 = adc_2bit(a & 3, b & 3, c)
	# 高2位计算
	t1, c1 = adc_2bit(a >> 2, b >> 2, c0)
	# 合并结果
	t2 = (t1 << 2) | t0
	return t2, c1

def adc_8bit(a, b, c):
	# 低4位计算
	t0, c0 = adc_4bit(a & 15, b & 15, c)
	# 高4位计算
	t1, c1 = adc_4bit(a >> 4, b >> 4, c0)
	# 合并结果
	t2 = (t1 << 4) | t0
	return t2, c1


assert adc_8bit(255, 1, 0) == (0, 1)
assert adc_8bit(255, 1, 1) == (1, 1)
assert adc_8bit(255, 255, 0) == (254, 1)
assert adc_8bit(255, 255, 1) == (255, 1)
