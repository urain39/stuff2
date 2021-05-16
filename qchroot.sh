#!/bin/sh


unset LD_PRELOAD


if [ -z "$QCHROOT_ARCH" ]; then
	QCHROOT_ARCH="$(uname -m)"
fi


show_usage() {
	echo "Usage: qchroot [OPTIONS] <NEWROOT> [PROGRAM [ARGS]]"
	echo ""
	echo "Options:"
	echo "    -a, --arch    set qemu arch manually. (default: $QCHROOT_ARCH)"
}


main() {
	while :; do
		case "$1" in
		"-a")
			shift
			QCHROOT_ARCH="$1"
			;;
		"--arch"*)
			QCHROOT_ARCH="${1:7}"
			;;
		*)
			break
			;;
		esac
		shift
	done

	if [ $# -lt 1 ]; then
		show_usage
		exit 1
	fi

	QCHROOT_NEWROOT="$1"
	shift

	if [ $# -lt 1 ]; then
		ls "$QCHROOT_NEWROOT/bin/su" > /dev/null 2>&1

		if [ $? = 0 ]; then
			QCHROOT_PROGRAM="/bin/su -"
		else
			QCHROOT_PROGRAM="/bin/sh -"
		fi
	else
		QCHROOT_PROGRAM="$@"
	fi

	proot \
		-q "qemu-$QCHROOT_ARCH" \
		-b /system:/system \
		-S "$QCHROOT_NEWROOT" \
		$QCHROOT_PROGRAM
}

main "$@"
