# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in strace, please report it
responsibly:

**Preferred method**: Use GitHub's private vulnerability reporting:
- Go to https://github.com/strace/strace/security/advisories/new
- This allows private discussion and coordinated disclosure

**Alternative methods**:
- Email the current maintainers listed in the [CREDITS.in](CREDITS.in) file
- Report to the mailing list: strace-devel@lists.strace.io

**Public disclosure**: For non-critical security issues, you may report them
on GitHub issues or the public mailing list. For critical vulnerabilities,
please use private reporting to allow time for a fix before public disclosure.

**What to include**:
- Description of the vulnerability
- Steps to reproduce
- Affected versions
- Potential impact assessment
- Any suggested fixes (optional)

## Security Considerations for strace Users

### Output Sensitivity

strace output may contain sensitive information:

- Process memory contents (strings, data structures)
- File paths and directory listings
- Network addresses and ports
- Credentials, tokens, or passwords passed as syscall arguments
- File descriptor contents

**Recommendation**: Always review strace output before sharing, especially
in public bug reports or discussions. Sensitive data should be redacted.

### Secure Usage Patterns

- Run strace with the minimum required privileges
- Be cautious when tracing security-sensitive processes
- Use filtering options (`-e trace=...`) to limit captured syscalls
- Sanitize output before sharing or storing in version control
- Be aware that traced processes can detect they are being traced

## Known Security Boundaries

strace is designed to trace processes, not to provide security isolation. It
should not be used as a security sandbox. Traced processes can:

- Detect they are being traced (e.g., via `ptrace(PTRACE_TRACEME, ...)`,
  checking `/proc/self/status`, timing analysis, and other methods)
- Evade tracing of child processes using `CLONE_UNTRACED` flag
- Attempt to exploit strace bugs via malformed syscall arguments
- Bypass tracing under certain conditions (race conditions, kernel bugs)

For sandboxing or security isolation, use dedicated tools like seccomp,
AppArmor, SELinux, or containers.
