def render(pos):
	step = randrange(-3, 3)
	newpos = pos + step
	if newpos >= 1 and newpos <= 7:
		pos = newpos
		frag = 0xff00 >> newpos
		return pos, format(frag, "#018b")
	return pos, None

def draw(times=100):
	pos = 3
	for i in range(times):
		pos, frag = render(pos)
		if frag:
			print(frag[2:])
