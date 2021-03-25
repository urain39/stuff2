def render(pos):
	step = randrange(-4, 4)
	newpos = pos + step
	if newpos >= 0 and newpos <= 8:
		pos = newpos
		frag = 0xff00 >> newpos
		return pos, format(frag, "#018b")
	return pos, None

def draw(times=100):
	pos = 3
	for i in range(times):
		pos, frag = render(pos)
		if frag:
			print(frag)
