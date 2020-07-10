{
	gsub(/\r\n?/, "\n")
	if (NF == 2 && $1 ~ /([A-Za-z_][0-9A-Za-z_]*),/) {
		gsub(/^,|,$/, "", $2)
		split($2, cglist, ",")
		l = length(cglist)
		for (i = 1; i <= l; i++)
			printf(" \"cg_%s\" => 1,\n", toupper(cglist[i]))
	}
}
