Build strace from git repository
================================

If you use a git version of strace source code, you must first generate the
build files that are included in release tarballs but not in the git
repository.

## Prerequisites

You will need the following tools to run `./bootstrap`:

- **autoconf** (version 2.69 or later)
- **automake** (version 1.14 or later)
- **gawk** (version 3 or later)

On Debian/Ubuntu:
```bash
apt-get install autoconf automake gawk
```

On Fedora/RHEL:
```bash
dnf install autoconf automake gawk
```

## Running bootstrap

From the git repository root:

```bash
./bootstrap
```

This generates the configure script and build system files.

## Next Steps

After running `./bootstrap`, follow the **[INSTALL](dist/INSTALL)** file for:

- Build requirements (compiler, libraries)
- Configuration options
- Building and testing instructions
- Installation

For a quick start:

```bash
./configure
make -j$(nproc)
make -j$(nproc) check
make install
```

See **[INSTALL](dist/INSTALL)** for detailed configure options and
**[README-configure](README-configure)** for generic GNU Autoconf information.
