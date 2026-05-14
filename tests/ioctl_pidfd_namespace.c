/*
 * Check decoding of PIDFD_GET_*_NAMESPACE ioctls.
 *
 * Copyright (c) 2026 The strace developers.
 * All rights reserved.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "tests.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <linux/pidfd.h>

static const char *errstr;

static int
do_ioctl(kernel_ulong_t cmd, kernel_ulong_t arg)
{
	int rc = ioctl(-1, cmd, arg);

	errstr = sprintrc(rc);

	return rc;
}

int
main(void)
{
	static const struct strval32 cmds[] = {
		{ ARG_STR(PIDFD_GET_CGROUP_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_IPC_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_MNT_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_NET_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_PID_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_PID_FOR_CHILDREN_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_TIME_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_TIME_FOR_CHILDREN_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_USER_NAMESPACE) },
		{ ARG_STR(PIDFD_GET_UTS_NAMESPACE) },
		{ ARG_STR(_IOC(_IOC_NONE, 0xff, 0xfe, 0xfd)) }
	};
	static const kernel_ulong_t args[] = {
		0,
		(kernel_ulong_t) 0xfacefeeddeadbeefULL
	};

	for (unsigned int i = 0; i < ARRAY_SIZE(cmds); ++i) {
		for (unsigned int j = 0; j < ARRAY_SIZE(args); ++j) {
			do_ioctl(cmds[i].val, args[j]);
			printf("ioctl(-1, " XLAT_FMT ", %#llx) = %s\n",
			       XLAT_SEL(cmds[i].val, cmds[i].str),
			       (unsigned long long) args[j],
			       errstr);
		}
	}

	puts("+++ exited with 0 +++");
	return 0;
}
