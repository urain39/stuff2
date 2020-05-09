static int n = 0xff00;

int is_big_endian()
{
	return *(char*)&n == 0xff;
}

int is_little_endian()
{
	return *(char*)&n == 0x00;
}
