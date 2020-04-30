"""
    function f(e, r) {
        e |= 0, r |= 0;
        var t = 0, n = 0, o = 0;
        if (t = R(20) | 0, W[t >> 2] = 10, W[t + 4 >> 2] = 43, W[t + 8 >> 2] = 54, W[t + 12 >> 2] = 111, 
        W[t + 16 >> 2] = 11, !((r | 0) > 0)) return void O(t);
        n = 0;
        do {
            o = e + n | 0, q[o >> 0] = W[t + (((n | 0) % 5 | 0) << 2) >> 2] ^ (X[o >> 0] | 0), 
            n = n + 1 | 0;
        } while ((n | 0) != (r | 0));
        O(t);
    }
"""

def decrypt(in_buf):
    i = 0
    key = [0x0A, 0x2B, 0x36, 0x6F, 0x0B]
    out_buf = []  # XXX: 默认好像是 4 字节编码，比较浪费？
    for ch in in_buf:
        out_buf.append(ch ^ key[i % 5])
        i += 1
    return bytes(out_buf)

def test(file_name):
    with open(file_name, "rb+") as f:
        in_buf = f.read()
        f.seek(0)
        f.write(decrypt(in_buf))

test("ed 想要得到你（姐）.mp3")
