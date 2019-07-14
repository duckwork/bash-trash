#!/usr/bin/env bash
# Trash management for bash
#
# Author: Dave Eddy <dave@daveeddy.com>
# and Case Duckworth <acdw@acdw.net>
# Date: 2019-07-14
# License: MIT

TRASH_DIR=${TRASH_DIR:-$HOME/.local/trash}
mkdir -p "$TRASH_DIR"

usage() { script=$(basename $0)
	cat <<-EOF
	$script: move things to trash, instead of deleting them.
	usage: $script FILES... | (-e|--empty) | (-q|--quiet) | (-h|--help)
		FILES:		which files to trash (move to \$TRASH_DIR)
		-e|--empty:	empty trash (rm -rf \$TRASH_DIR/*)
		-q|--quiet:	exit 0 if trash is empty, else 1
		-h|--help:	show this help
	\$TRASH_DIR can be set in the environment,
	but it defaults to ~/.local/trash.
	EOF
}

# trash each argument, or show the state of the trash if no
# arguments are given
trash() {
	# list trash dir if no arguments given
	if [[ -z $1 ]]; then
		if _bash_trash_is_empty; then
			echo "$TRASH_DIR: trash is empty"
		else
			# TODO: GNU du dep required to print the total
			du -csh "$TRASH_DIR"/*
		fi
		return
	fi

	# loop each argument and move to the trash
	local f
	for f in "$@"; do
		local b=$(basename "$f") # basename is sane here, ${f##*/} isn't
		local fname=$b
		local i=1
		while [[ -e $TRASH_DIR/$fname ]]; do
			fname=$b.$i
			((i++))
		done
		mv "$f" "$TRASH_DIR/$fname"
	done
}

# empty the trash
emptytrash() {
	command rm -rf "$TRASH_DIR"/*
}

# return 0 if the trash dir is empty
_bash_trash_is_empty() {
	(
	shopt -s nullglob
	files=("$TRASH_DIR"/*)
	[[ -z ${files[0]} ]]
	)
	return $?
}

main() {
	case "$1" in
		trash) shift; trash "$@" ;;
		-e|--empty) shift; emptytrash ;;
		-q|--quiet) exit $(_bash_trash_is_empty) ;;
		-h|--help) usage ;;
		*) trash "$@" ;;
	esac
}

main "$@"
