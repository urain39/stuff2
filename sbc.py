def sbc(a, b, c):
	# a - b
	t0 = a ^ b
	# 判断借位
	c0 = int(not a) & b
	# (a - b) - c
	t1 = t0 ^ c
	# 判断借位
	c1 = int(not t0) & c
	# 最终借位判断
	c2 = c0 | c1
	return t1, c2

def sbc_2bit(a, b, c):
	# 低位计算
	t0, c0 = sbc(a & 1, b & 1, c)
	# 高位计算
	t1, c1 = sbc(a >> 1, b >> 1, c0)
	# 合并结果
	t2 = (t1 << 1) | t0
	return t2, c1

def sbc_4bit(a, b, c):
	# 低2位计算
	t0, c0 = sbc_2bit(a & 3, b & 3, c)
	# 高2位计算
	t1, c1 = sbc_2bit(a >> 2, b >> 2, c0)
	# 合并结果
	t2 = (t1 << 2) | t0
	return t2, c1

def sbc_8bit(a, b, c):
	# 低4位计算
	t0, c0 = sbc_4bit(a & 15, b & 15, c)
	# 高4位计算
	t1, c1 = sbc_4bit(a >> 4, b >> 4, c0)
	# 合并结果
	t2 = (t1 << 4) | t0
	return t2, c1


assert sbc_8bit(255, 255, 0) == (0, 0)
assert sbc_8bit(255, 255, 1) == (255, 1)
assert sbc_8bit(0, 1, 0) == (255, 1)
assert sbc_8bit(0, 1, 1) == (254, 1)
