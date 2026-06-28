# strace Glossary

This document defines project-specific terminology used throughout the
strace codebase and documentation. For detailed API references and
implementation guides, see the linked documentation.

## General Terms

### strace

The system call tracer utility itself. Also refers to the project,
codebase, and main executable.

### ptrace

Linux kernel facility that allows one process to observe and control
another process's execution. strace's primary mechanism for tracing
system calls.

### tracee

A process being traced by strace (the "traced process").

### tracer

The strace process itself (the "tracing process").

### UAPI

**User-space API** — Linux kernel headers defining the stable interface
between kernel and userspace. Located in `include/uapi/` and
`arch/*/include/uapi/` since kernel 3.5.

### bundled headers

Vendored Linux kernel UAPI headers included in the `bundled/` directory.
Provide build portability and forward compatibility when system headers
lack newer definitions. See [README-bundled.md](README-bundled.md).

## Core Data Structures

### tcb

**Trace Control Block** - `struct tcb` defined in `src/defs.h`. Represents
a single traced process or thread. Contains process ID, syscall state,
arguments, flags, and personality information.

See [INTERNALS.md](INTERNALS.md) for field details.

### sysent

**System call entry** - `struct_sysent` defined in `src/sysent.h`. Maps
syscall numbers to decoder functions. Contains argument count, trace
flags, syscall name, and function pointer.

### syscallent

**System call entry table** - Array of `struct_sysent` entries, one per
syscall number. Located in `src/linux/{arch}/syscallent.h` files.

See [INTERNALS.md](INTERNALS.md) for table structure.

### ioctlent

**Ioctl entry table** - Maps ioctl command numbers to symbolic names.
Populated from `src/linux/{arch}/ioctls_inc{pers}.h` and
`src/linux/{arch}/ioctls_arch{pers}.h`files.

### errnoent

**Errno table** - Array mapping errno numbers to their string names
(e.g., `[2] = "ENOENT"`). Populated from `src/linux/{arch}/errnoent.h`.

### signalent

**Signal table** - Array mapping signal numbers to their string names
(e.g., `"SIGHUP"`, `"SIGINT"`). Populated from
`src/linux/{arch}/signalent.h`.

## Syscall Decoding

### decoder

A function (using `SYS_FUNC()` macro) that decodes and pretty-prints a
syscall's arguments and return value.

See [HOWTO_ADD_SYSCALL.md](HOWTO_ADD_SYSCALL.md).

### SYS_FUNC()

Macro for defining syscall decoder functions. Expands to
`int SYS_FUNC_NAME(sys_name)(struct tcb *tcp)`, with MPERS prefixes added
when needed. See [README-mpers.md](README-mpers.md) and
[DECODER_API.md](DECODER_API.md).

### SEN()

**Syscall Entry Number** macro used in syscallent tables. Expands to two
fields: the `sen` enum value (from `src/sen.h`) and the `sys_func`
function pointer. See [HOWTO_ADD_SYSCALL.md](HOWTO_ADD_SYSCALL.md).

### one-phase decoding

Decoder that fully decodes on syscall entry and returns `RVAL_DECODED`.
The simpler, more common pattern for syscalls with only input arguments.

See [DECODER_API.md](DECODER_API.md) for examples.

### two-phase decoding

Decoder that runs on both syscall entry and exit, used for syscalls with
output parameters. Returns `0` on entry to signal "continue decoding".

See [DECODER_API.md](DECODER_API.md) for examples.

### entering() / exiting()

Macros that test whether the current syscall invocation is at entry or
exit. Used in two-phase decoders. See [DECODER_API.md](DECODER_API.md).

### RVAL_DECODED

Return value flag meaning "fully decoded, no need to call decoder on
syscall exit". Signals one-phase decoding.

### RVAL_FD

Return value flag meaning "the syscall returns a file descriptor". Used
by strace's `-y` (print paths) and `--trace-fds` features.

### RVAL_TID

Return value flag meaning "the syscall returns a thread/process ID"
(e.g., clone, fork).

### RVAL_IOCTL_DECODED

Return value flag used by ioctl sub-decoders to indicate the decoder has
printed the argument. Converted to `RVAL_DECODED` by `SYS_FUNC(ioctl)`.

See [HOWTO_ADD_IOCTL.md](HOWTO_ADD_IOCTL.md) for details.

### print helpers

Functions for printing decoded syscall arguments: printaddr, printstr,
printpath, printxval, printflags, PRINT_FIELD_* macros, tprint_*, etc.

See [DECODER_API.md](DECODER_API.md) for comprehensive reference.

## Xlat System

### xlat

**Translation table** - Maps numeric constants to symbolic names (e.g.,
`2` → `SEEK_END` for lseek whence argument).

### xlat file

Input file (`src/xlat/*.in`) defining a translation table. Processed by
`gen.sh` to generate C header files. Supports directives for controlling
constant sourcing and filtering.

See [README-xlat.md](README-xlat.md) for file format details.

## Personalities

### personality

An ABI (Application Binary Interface) variant on a multi-personality
architecture. For example, x86_64 supports three personalities: native
64-bit (x86_64), 32-bit compat (i386), and x32 (32-bit pointers with
64-bit longs).

### MPERS

**Multi-Personality Support** - Build system mechanism that compiles
decoder files multiple times with different compiler flags to handle
structures whose layout varies between personalities.

See [README-mpers.md](README-mpers.md) for details.

### SUPPORTED_PERSONALITIES

Constant (1, 2, or 3) indicating how many personalities the current
architecture supports. Defined based on configure-time detection.

### current_personality

Global variable (or `tcp->currpers` field) holding the tracee's
personality index (0, 1, or 2).

## Trace Flags

Syscallent table flags indicating syscall categories for filtering
(`-e trace=<set>`):

| Flag | Full Name                 | Description                       |
|------|---------------------------|-----------------------------------|
| TD   | TRACE_DESC                | File descriptor operations        |
| TF   | TRACE_FILE                | File path operations              |
| TI   | TRACE_IPC                 | Inter-process communication       |
| TN   | TRACE_NETWORK             | Network operations                |
| TP   | TRACE_PROCESS             | Process management                |
| TS   | TRACE_SIGNAL              | Signal operations                 |
| TM   | TRACE_MEMORY              | Memory management                 |
| TST  | TRACE_STAT                | stat syscalls                     |
| TLST | TRACE_LSTAT               | lstat syscalls                    |
| TFST | TRACE_FSTAT               | fstat syscalls                    |
| TSTA | TRACE_STAT_LIKE           | All stat-family syscalls          |
| TSF  | TRACE_STATFS              | statfs syscalls                   |
| TFSF | TRACE_FSTATFS             | fstatfs syscalls                  |
| TSFA | TRACE_STATFS_LIKE         | All statfs-family syscalls        |
| PU   | TRACE_PURE                | Pure getters (no arguments)       |
| NF   | SYSCALL_NEVER_FAILS       | Always succeeds                   |
| MA   | MAX_ARGS                  | Uses maximum argument count       |
| SI   | MEMORY_MAPPING_CHANGE     | Changes memory mappings           |
| CST  | COMPAT_SYSCALL_TYPES      | Compat syscall with compat types  |
| TSD  | TRACE_SECCOMP_DEFAULT     | Seccomp filter default set        |
| TC   | TRACE_CREDS               | Credential changes                |
| TCL  | TRACE_CLOCK               | Clock operations                  |
| CC   | COMM_CHANGE               | Changes process comm (name)       |
| SE   | TRACE_INDIRECT_SUBCALL    | Indirect socket/ipc subcall       |

See `src/sysent.h` and `src/sysent_shorthand_defs.h` for authoritative
definitions.

## Advanced Features

### seccomp-bpf

Kernel-level syscall filtering. The `--seccomp-bpf` option installs a
seccomp filter that stops the tracee only on syscalls strace cares
about, significantly improving performance.

### inject / tamper

Syscall injection and tampering feature (`-e inject=`). Allows modifying
syscall arguments, return values, or injecting errors for testing.

## Other Terms

### kernel_ulong_t / kernel_long_t

Type representing a kernel-width integer (may be 32-bit or 64-bit
depending on personality, even when userspace long is different).

### BASE_NR

Constant used in generic syscall tables. Syscall numbers in
`syscallent-common.h` are offset by `BASE_NR` to allow
architecture-specific overrides.

### dispatch_wordsize / current_wordsize

Size of a "word" (pointer) for the current personality. Used for
decoding pointer-sized values correctly.

### current_klongsize

Size of kernel's `long` type for current personality.

### tcp->u_arg[]

Array holding syscall arguments. `tcp->u_arg[0]` through `tcp->u_arg[5]`
(or `u_arg[6]` on MIPS o32) contain the syscall's arguments.

### qual_flg

Qualifier flags in tcb indicating which trace sets this syscall belongs
to (file, desc, process, etc.).

## See Also

- [DECODER_API.md](DECODER_API.md) - Print helper and decoder API
  reference
- [INTERNALS.md](INTERNALS.md) - Architecture and design overview
- [HOWTO_ADD_SYSCALL.md](HOWTO_ADD_SYSCALL.md) - Adding syscall decoders
- [HOWTO_ADD_IOCTL.md](HOWTO_ADD_IOCTL.md) - Adding ioctl decoders
- [README-xlat.md](README-xlat.md) - Xlat system documentation
- [README-mpers.md](README-mpers.md) - MPERS system documentation
- [src/defs.h](../src/defs.h) - Core definitions and macros
- [src/sysent.h](../src/sysent.h) - Syscall entry structure
