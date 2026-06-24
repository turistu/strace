# AGENTS.md

This file provides guidance to AI coding agents when working with code in this
repository.

## Project Overview

strace is a diagnostic, debugging and instructional userspace utility for Linux
that monitors and tampers with interactions between processes and the Linux
kernel. It traces system calls, signal deliveries, and process state changes
using the kernel's ptrace facility.

The codebase supports 30+ architectures and maintains backward compatibility
across many Linux kernel versions. Development emphasizes accurate syscall
decoding, comprehensive constant translation (xlat), and strict commit message
formatting for automated ChangeLog generation.

## Build System

### Initial Setup (Git Clone)

```bash
./bootstrap
./configure
make -j$(nproc)
make -j$(nproc) check
```

The `bootstrap` script generates necessary autoconf/automake files.

### Testing

See `doc/HOWTO_TEST.md` for running tests.

## Directory Structure

- **src/** - Main source code (~70K lines)
- **tests/** - Comprehensive test suite with per-syscall tests
- **bundled/** - Bundled Linux UAPI headers for build portability
- **maint/** - Maintenance scripts for xlat generation, ioctl tables, release management
- **doc/** - Developer documentation

See `doc/INTERNALS.md` for key files and `doc/README.md` for the documentation
index.

## Commit Message Requirements

You MUST read `doc/COMMIT-MESSAGES.md` before writing any commit message.
Strace uses strict ChangeLog-format commit messages for automated ChangeLog
generation.

Structure:
```
summary line (imperative mood, <72 chars)

* file.c (function_name): Description of change.
(another_function): Another change in same file.
* file2.c: Description.
```

All commits must end with:
```
Assisted-by: AGENT_NAME:MODEL_VERSION
```

Reference kernel commits when updating for kernel changes.
Update `NEWS` for user-visible changes.

## Code Style

Tabs for indentation, `/* */` comments only (no `//`), 80-character line limit.
See `CONTRIBUTING.md` for the full style guide.

## Development Workflow

For adding syscalls, ioctls, or netlink decoders,
follow the relevant HOWTO guide in `doc/`:

- **New syscall**: `doc/HOWTO_ADD_SYSCALL.md`
- **New ioctl decoder**: `doc/HOWTO_ADD_IOCTL.md`
- **New netlink decoder**: `doc/HOWTO_ADD_NETLINK.md`
- **Xlat updates**: `doc/HOWTO_UPDATE_XLAT_AFTER_UAPI.md`
- **Writing tests**: `doc/HOWTO_TEST.md`

## Important Files

- **src/defs.h** - Main header with core definitions and function declarations
- **src/sysent.h** - Syscall table entry structures
- **NEWS** - Release notes (update for user-visible changes)

See `doc/INTERNALS.md` for architecture details and the complete file reference.

## Architecture Considerations

CI currently tests x86, x86_64, and aarch64. See `doc/README-mpers.md`
for multi-architecture and multi-personality considerations.

## Resources

- GitHub repository: https://github.com/strace/strace
- Issue tracker: https://github.com/strace/strace/issues
- Contribution guide: `CONTRIBUTING.md`
- Documentation index: `doc/README.md`
