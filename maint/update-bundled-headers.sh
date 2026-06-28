#!/bin/sh -efu
# Update bundled Linux UAPI headers from a checked-out Linux kernel tree.
#
# Copyright (c) 2026 The strace developers.
# All rights reserved.
#
# SPDX-License-Identifier: LGPL-2.1-or-later

me="${0##*/}"
mydir="${0%/*}"

msg()
{
	printf >&2 '%s\n' "$me: $*"
}

error()
{
	printf >&2 '%s: error: %s\n' "$me" "$*"
}

fatal()
{
	error "$@"
	exit 1
}

print_help()
{
	cat <<__EOF__
$me [-h|--help] [-j JOBS] [-n] LINUX_SRC_DIR

Update bundled Linux UAPI headers from a checked-out Linux kernel source
tree.  Runs 'make headers_install' in LINUX_SRC_DIR and copies the
sanitized headers to the bundled/ directory.  The list of files to copy
is derived from bundled/Makefile.am EXTRA_DIST.

Options:
  -h, --help    Print this message and exit.
  --commit      Commit the updated files with a generated commit message.
  -j JOBS       Number of parallel make jobs (default: \$(nproc) or 1).
  -n            Dry run: show what would be copied without making changes.
__EOF__

	exit "$@"
}

print_usage()
{
	print_help 1 >&2
}

do_commit=0
dry_run=0
jobs=

while :; do
	case "${1:-}" in
	-h|--help)
		print_help 0
		;;
	--commit)
		do_commit=1
		;;
	-j)
		shift
		[ $# -gt 0 ] ||
			print_usage
		jobs="$1"
		;;
	-n)
		dry_run=1
		;;
	-*)
		print_usage
		;;
	*)
		break
		;;
	esac

	shift
done

[ $do_commit -eq 0 ] || [ $dry_run -eq 0 ] ||
	fatal "--commit and -n are mutually exclusive"

[ $# -eq 1 ] ||
	print_usage

linux_src="$1"; shift

[ -d "$linux_src" ] ||
	fatal "not a directory: $linux_src"
[ -f "$linux_src/Makefile" ] ||
	fatal "no Makefile in $linux_src -- is this a Linux kernel tree?"
[ -d "$linux_src/include/uapi/linux" ] ||
	fatal "no include/uapi/linux in $linux_src -- is this a Linux kernel tree?"

kernel_tag="$(git -C "$linux_src" describe --tags 2>/dev/null)" ||
	kernel_tag=
if [ -z "$kernel_tag" ]; then
	version_h_src="$linux_src/include/uapi/linux/version.h"
	if [ -f "$version_h_src" ]; then
		k_major="$(sed -n 's/^#define LINUX_VERSION_MAJOR //p' "$version_h_src")"
		k_patch="$(sed -n 's/^#define LINUX_VERSION_PATCHLEVEL //p' "$version_h_src")"
		kernel_tag="v${k_major}.${k_patch}"
	else
		kernel_tag="unknown"
	fi
fi

strace_top="$(cd "$mydir/.." && pwd -P)"
bundled_dir="$strace_top/bundled"
makefile_am="$bundled_dir/Makefile.am"

[ -f "$makefile_am" ] ||
	fatal "bundled/Makefile.am not found at $makefile_am"

[ -n "$jobs" ] || jobs=$(nproc 2>/dev/null) || jobs=1

tmpdir=
cleanup()
{
	trap - EXIT
	[ -z "$tmpdir" ] ||
		rm -rf -- "$tmpdir"
	exit "$@"
}
trap 'cleanup $?' EXIT
trap 'cleanup 1' HUP PIPE INT QUIT TERM

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/$me.XXXXXX")"

file_list="$(
	sed -n '/^EXTRA_DIST/,/^[^[:space:]#\\]/p' "$makefile_am" |
	sed 's/\\$//' |
	sed 's/EXTRA_DIST[[:space:]]*=[[:space:]]*//' |
	tr -s '[:space:]' '\n' |
	grep '\.h$'
)"

generic_files="$(printf '%s\n' "$file_list" | grep -v '^linux/arch/' ||:)"
arch_files="$(printf '%s\n' "$file_list" | grep '^linux/arch/' ||:)"
arch_list="$(printf '%s\n' "$arch_files" |
	sed -n 's|^linux/arch/\([^/]*\)/.*|\1|p' | sort -u)"

n_generic="$(printf '%s\n' "$generic_files" | grep -c . ||:)"
msg "found $n_generic generic header(s)"
if [ -n "$arch_list" ]; then
	n_arch="$(printf '%s\n' "$arch_files" | grep -c . ||:)"
	n_arch_list="$(printf '%s\n' "$arch_list" | grep -c . ||:)"
	msg "found $n_arch arch-specific header(s) across $n_arch_list architecture(s)"
fi

generic_hdr_path="$tmpdir/generic"
msg "running make headers_install..."
make -C "$linux_src" -j"$jobs" headers_install \
	INSTALL_HDR_PATH="$generic_hdr_path" >/dev/null ||
	fatal "make headers_install failed"

find "$generic_hdr_path" -name '*.h' \
	-exec "$mydir/fix-whitespace.sh" {} +

for arch in $arch_list; do
	arch_hdr_path="$tmpdir/arch-$arch"
	if [ ! -d "$linux_src/arch/$arch" ]; then
		msg "skipping ARCH=$arch (removed from kernel tree)"
		continue
	fi
	msg "running make headers_install ARCH=$arch..."
	make -C "$linux_src" -j"$jobs" headers_install \
		ARCH="$arch" INSTALL_HDR_PATH="$arch_hdr_path" \
		>/dev/null ||
		fatal "make headers_install ARCH=$arch failed"
	find "$arch_hdr_path" -name '*.h' \
		-exec "$mydir/fix-whitespace.sh" {} +
done

unchanged=0
skipped=0
changed_files=""

for entry in $generic_files; do
	rel="${entry#linux/include/uapi/}"
	src="$generic_hdr_path/include/$rel"
	dst="$bundled_dir/$entry"

	if [ ! -f "$src" ]; then
		error "missing from headers_install output: $rel"
		skipped=$((skipped + 1))
		continue
	fi

	if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
		unchanged=$((unchanged + 1))
		continue
	fi

	changed_files="$changed_files $entry"

	if [ $dry_run -eq 1 ]; then
		msg "would update: $entry"
	else
		dst_dir="${dst%/*}"
		[ -d "$dst_dir" ] || mkdir -p "$dst_dir"
		cp "$src" "$dst"
		msg "updated: $entry"
	fi
done

for entry in $arch_files; do
	arch="$(printf '%s\n' "$entry" | sed 's|^linux/arch/\([^/]*\)/.*|\1|')"
	rel="$(printf '%s\n' "$entry" | sed "s|^linux/arch/$arch/include/uapi/||")"
	src="$tmpdir/arch-$arch/include/$rel"
	dst="$bundled_dir/$entry"

	if [ ! -f "$src" ]; then
		error "missing from headers_install ARCH=$arch output: $rel"
		skipped=$((skipped + 1))
		continue
	fi

	if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
		unchanged=$((unchanged + 1))
		continue
	fi

	changed_files="$changed_files $entry"

	if [ $dry_run -eq 1 ]; then
		msg "would update: $entry"
	else
		dst_dir="${dst%/*}"
		[ -d "$dst_dir" ] || mkdir -p "$dst_dir"
		cp "$src" "$dst"
		msg "updated: $entry"
	fi
done

set -- $changed_files
changed=$#
total=$((changed + unchanged + skipped))

msg ""
msg "summary: $total file(s) processed, $changed changed, $unchanged unchanged, $skipped skipped"

if [ $changed -gt 0 ]; then
	msg ""
	msg "changed files:"
	for f; do
		msg "  $f"
	done

	version_h="$bundled_dir/linux/include/uapi/linux/version.h"
	if [ -f "$version_h" ]; then
		kver_major="$(sed -n 's/^#define LINUX_VERSION_MAJOR //p' "$version_h")"
		kver_patch="$(sed -n 's/^#define LINUX_VERSION_PATCHLEVEL //p' "$version_h")"
		kver_sub="$(sed -n 's/^#define LINUX_VERSION_SUBLEVEL //p' "$version_h")"
		if [ -n "$kver_major" ]; then
			msg ""
			msg "bundled kernel version is now ${kver_major}.${kver_patch}.${kver_sub}"
		fi
	fi

	if [ $do_commit -eq 1 ]; then
		set -- $(printf 'bundled/%s\n' "$@")
		first=$1; shift
		commit_msg="$tmpdir/commit-msg"
		{
			printf '%s\n' \
				"bundled: update linux UAPI headers to $kernel_tag" \
				'' \
				"Headers updated automatically using $me script." \
				''
			printf '* %s: Update to\n' "$first"
			printf "headers_install'ed Linux kernel %s.\n" "$kernel_tag"
			if [ $# -gt 0 ]; then
				printf '* %s: Likewise.\n' "$@"
			fi
		} > "$commit_msg"
		git -C "$strace_top" add -- "$first" "$@"
		git -C "$strace_top" commit -F "$commit_msg"
		msg "committed"
	fi
else
	msg "no files changed -- bundled headers are already up to date"
fi
