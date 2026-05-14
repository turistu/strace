/*
 * Copyright (c) 2026 Dmitry V. Levin <ldv@strace.io>
 * All rights reserved.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "tests.h"
#include <unistd.h>

int main(int argc, char **argv)
{
	if (argc < 2)
		error_msg_and_fail("argc < 2");

	(void) execve(argv[1], argv + 1, NULL);

	perror_msg_and_fail("execve: %s", argv[1]);
}
