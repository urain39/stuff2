#!/bin/sh


unset LD_PRELOAD


QCHROOT_FORCE_FOREIGN_BINARY="PROOT_FORCE_FOREIGN_BINARY=true"


if [ -z "$QCHROOT_ARCH" ]; then
	QCHROOT_ARCH="$(uname -m)"
fi


show_usage() {
	echo "Usage: qchroot [OPTIONS] <NEWROOT> [PROGRAM [ARGS]]"
	echo ""
	echo "Options:"
	echo "    -a    set QEMU arch manually. (default: $QCHROOT_ARCH)"
	echo "    -Q    do NOT use QEMU for host binaries. (default: false)"
}


main() {
	while :; do
		case "$1" in
		"-a")
			shift
			QCHROOT_ARCH="$1"
			;;
		"-Q")
			unset QCHROOT_FORCE_FOREIGN_BINARY
			;;
		"-"*)
			echo "Invalid option $1" >&2
			exit 1
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
			QCHROOT_PROGRAM="/bin/sh -l"
		fi
	else
		QCHROOT_PROGRAM="$@"
	fi

	eval "$QCHROOT_FORCE_FOREIGN_BINARY" proot \
		-q "qemu-$QCHROOT_ARCH" \
		-b /system:/system \
		-S "$QCHROOT_NEWROOT" \
		--kill-on-exit \
		"$QCHROOT_PROGRAM"
}

main "$@"
