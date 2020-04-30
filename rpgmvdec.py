def decode(in_buf, key):
    # 简单判断文件格式
    if in_buf[0:8] != b"RPGMV\x00\x00\x00":
        raise TypeError("Wrong file!")

    # 得到加密区域
    enc_area = list(in_buf[16:32])

    # 解密加密区域
    i = 0
    while i < 16:
        enc_area[i] = enc_area[i] ^ key[i]
        i += 1

    # 返回原始数据
    return bytes(enc_area) + in_buf[32:]

def test(file_, out_file, key):
    with open(file_, "rb") as f:
        out_buf = decode(f.read(), key)

    with open(out_file, "wb") as f:
        f.write(out_buf)

test("ZW2.rpgmvp", "ZW2.png", [ 13, 22, 76, 11, 149, 92, 42, 226, 140, 190, 39, 3, 253, 198, 0, 134 ])
