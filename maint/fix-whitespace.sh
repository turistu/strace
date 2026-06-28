#!/bin/sh -efu
# Fix git whitespace issues in the specified files.
#
# Copyright (c) 2026 The strace developers.
# All rights reserved.
#
# SPDX-License-Identifier: LGPL-2.1-or-later

for f; do
	sed -i \
		-e 's/[[:space:]]*$//' \
		-e ':a' -e 's/^\([[:space:]]*\) 	/\1	/' -e 'ta' \
		"$f"
	sed -i -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}' "$f"
done
