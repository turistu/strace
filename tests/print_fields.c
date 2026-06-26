/*
 * Copyright (c) 2016-2017 Dmitry V. Levin <ldv@strace.io>
 * Copyright (c) 2017-2026 The strace developers.
 * All rights reserved.
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "print_fields.h"

void
tprints_field_name(const char *name)
{
	STRACE_PRINTF("%s=", name);
}

void
tprint_array_begin(void)
{
	STRACE_PRINTS("[");
}

void
tprint_array_next(void)
{
	STRACE_PRINTS(", ");
}

void
tprint_array_end(void)
{
	STRACE_PRINTS("]");
}
