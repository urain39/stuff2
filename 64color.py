## 64 Colors
# 4*4*4=64
# 256/4=64

c = 0
for r in range(0, 256, 64):
    for g in range(0, 256, 64):
        for b in range(0, 256, 64):
            print(r, g, b)
            c += 1

print("%s color(s)." % c)
