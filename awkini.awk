BEGIN {
	INDEX = 0
	DATABASE[KEY] = \
		SECTION = VALUE = KEY = ""
}

{
	if ($0 ~ /^\[.+\]$/) {
		gsub(/^\[|\]$/, "", $0)
		SECTION = $0

		next
	}

	gsub(/^[ \t]+|[ \t]+$/, "", $0)
	INDEX = index($0, "=")

	if (!INDEX)
		next

	KEY = sprintf("%s.%s",
		SECTION,
		substr($0, 1, INDEX - 1))
	sub(/[ \t]+$/, "", KEY)

	VALUE = substr($0, INDEX + 1)
	sub(/^[ \t]+/, "", VALUE)

	#printf("KEY=%s, VALUE=%s\n", KEY, VALUE)
	DATABASE[KEY] = VALUE
}

END {
	printf("%s", DATABASE[QUERY])
}
