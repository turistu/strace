# Contributing to strace

Thank you for your interest in contributing to strace!

## License

strace is released under the LGPL-2.1-or-later license. The test suite
is GPL-2.0-or-later. Bundled kernel headers are GPL-2.0 with the Linux
syscall exception. By contributing, you agree to license your code under
these terms.

## AI-assisted Contributions

Contributors must fully own their contributions — able to reason about
them, explain design decisions, and act as the code owner. AI tools
cannot be credited as author or co-author. As with all submissions,
authors are responsible for ensuring license compatibility.

## Getting Started

### Getting the Source Code

Clone the repository from GitHub:

```bash
git clone https://github.com/strace/strace.git
```

### Building from Source

See [INSTALL-git.md](INSTALL-git.md) for git build instructions and
[INSTALL](dist/INSTALL) for detailed build requirements and configure options.

## Communication

### GitHub (Primary)

Development primarily happens on GitHub:
- **Issues**: https://github.com/strace/strace/issues - bug reports, feature
  requests, discussions
- **Pull Requests**: https://github.com/strace/strace/pulls - code
  contributions
- **Discussions**: Use issue comments or PR reviews for technical discussions

### Mailing List (Alternative)

The strace-devel mailing list is also available:
- **Subscribe**: https://lists.strace.io/mailman/listinfo/strace-devel
- **Archives**: https://lists.strace.io/pipermail/strace-devel/
- Use for longer design discussions or when you prefer email-based workflow

**Mailing List Etiquette:**
- Send plain text emails only (no HTML)
- Do not top-post; reply inline or bottom-post
- Review the mailing list archives to understand discussion format

## Commit Messages

Commit messages must follow a strict format for automated ChangeLog generation.

**Structure:**
```
summary line (imperative mood, <72 chars)

<one-line summary>

Descriptive text explaining the change.

* file.c (function_name): Description of change.
(another_function): Another change in same file.
* file2.c: Description.
```

See [doc/COMMIT-MESSAGES.md](doc/COMMIT-MESSAGES.md) for comprehensive
guidelines, including common patterns and examples.

## Code Style

strace follows Linux kernel coding style with some exceptions:

- Tabs for indentation (not spaces)
- No C++ style comments (`//`) - use `/* */` exclusively
- Use designated initializers in struct initialization
- 80-character line limit

Running `scripts/checkpatch.pl` from the Linux kernel is optional but preferred:
- https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/scripts/checkpatch.pl

For the full Linux kernel coding style reference:
- https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Documentation/process/coding-style.rst

## Documentation

See [doc/README.md](doc/README.md) for the comprehensive documentation index.

## Testing

All new features and bug fixes must include tests. See
[doc/HOWTO_TEST.md](doc/HOWTO_TEST.md) for comprehensive information on:

- Running tests (full suite, specific tests, verbose output)
- Writing test programs
- Test registration
- Framework helpers and common patterns

## Documentation Requirements

All changes must be documented:

- **NEWS file**: Update `NEWS` for all user-visible changes (new syscalls, new options, bug fixes affecting output)
- **Man page**: Update `doc/strace.1.in` for any command-line interface changes
- **Help output**: New options must appear in both `-h` output and the man page

## Submitting Patches

### Via Pull Request (Recommended)

GitHub pull requests are the primary method for contributing code:

1. Fork the repository on GitHub: https://github.com/strace/strace
2. Create a feature branch from master
3. Make your changes with proper commit messages (see
   [doc/COMMIT-MESSAGES.md](doc/COMMIT-MESSAGES.md))
4. Push to your fork
5. Open a pull request against the master branch

**Before submitting a PR:**
- Ensure all commits follow the commit message format
- Verify the branch builds and tests pass
- Include tests for new features or bug fixes
- Update NEWS and documentation as needed

### Via Mailing List (Alternative)

Patches can also be submitted via email to strace-devel@lists.strace.io:

**1. Stage your changes:**
```bash
git add <files>                # Add specific files
git add -i                     # Interactive staging (recommended)
```

**2. Commit with proper message:**
```bash
git commit
```
Follow the commit message format from [doc/COMMIT-MESSAGES.md](doc/COMMIT-MESSAGES.md).

**3. Create patch files:**

For a single commit:
```bash
git format-patch -1 HEAD
```

For multiple commits:
```bash
git format-patch HEAD~N      # Last N commits
git format-patch <base-commit>..HEAD
```

**4. Quality check (optional but recommended):**
```bash
# Download checkpatch.pl from Linux kernel
curl -O https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/scripts/checkpatch.pl
chmod +x checkpatch.pl
./checkpatch.pl --no-tree <patch-file>
```

**5. Send patches:**
```bash
git send-email --to=strace-devel@lists.strace.io *.patch
```

If you don't have `git send-email` configured, you can attach the patch files to a plain-text email.

**Patch versioning:** If submitting a revised version of a patch:
```bash
git format-patch -1 HEAD -v2    # Second version
git format-patch -1 HEAD -v3    # Third version, etc.
```


### Before Submitting

**Checklist:**
- [ ] Code builds: `make -j$(nproc)`
- [ ] Tests pass: `make -j$(nproc) check`
- [ ] Relevant tests run for your changes: `make check TESTS=<your-test>`
- [ ] Commit message follows format in doc/COMMIT-MESSAGES.md
- [ ] NEWS file updated (if user-visible change)
- [ ] Man page updated (if interface change): doc/strace.1.in
- [ ] Tests included (for new features or bug fixes)
- [ ] No compiler warnings introduced
- [ ] Patches are bisectable (each commit builds and works)

## Architecture Considerations

strace supports 30+ architectures. When making changes:

- Syscall numbers vary by architecture
- Some syscalls are architecture-specific
- Argument passing differs between architectures (e.g., MIPS o32 has 7-argument syscalls)
- Consider multi-personality systems (x86_64 can run i386 binaries)

CI tests x86, x86_64, and aarch64. Manual testing on other architectures is appreciated but not required.

## Need Help?

- Check the documentation links above
- Open a GitHub issue: https://github.com/strace/strace/issues
- Ask on the mailing list: strace-devel@lists.strace.io
- See this guide and linked documentation for comprehensive information
- Review existing similar code for patterns

## Release Process

For maintainers, see [maint/README-release](maint/README-release) for the release checklist.
