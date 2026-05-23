# 0004 - Bash Over Other Languages

## Status
Accepted

## Context
Scripts need to be portable, easy to modify, and work natively on macOS without additional dependencies. The target environment is primarily macOS with bash/zsh shells.

## Decision
Use bash for all scripts. Bash is native to macOS, works with both bash and zsh shells, and provides good system integration (PATH manipulation, file operations, process management).

## Alternatives considered
- **Python**: Pros: More readable, better error handling, rich ecosystem. Cons: Requires Python installation/version management, adds dependency, less native macOS integration.
- **Zsh**: Pros: Native on macOS (default shell), more features than bash. Cons: Less portable, scripts wouldn't work on systems with old zsh or bash-only environments.
- **Node.js/JavaScript**: Pros: Familiar to many developers, good libraries. Cons: Requires Node.js installation, adds significant dependency, overkill for system scripts.
- **Rust/Go**: Pros: Compiled, fast, modern. Cons: Requires compilation, adds build step, harder to modify quickly.

## Consequences
**Positive:**
- No external dependencies (bash is native on macOS)
- Works with both bash and zsh shells
- Fast execution (no interpreter startup overhead)
- Easy to modify (text editor, no compilation)
- Good system integration (native commands, PATH, etc.)
- Portable across macOS versions

**Negative:**
- Bash error handling can be verbose
- Less powerful than modern languages for complex logic
- No built-in JSON parsing (requires `jq` for API responses)
- String manipulation can be awkward

**Risks:**
- Bash version differences between macOS versions. Mitigated by:
  - Using POSIX-compliant features where possible
  - Testing on different macOS versions
  - Avoiding bash-specific features when not needed

## Links
- Implementation: All scripts in `scripts/` directory
- Dependencies: `jq` for JSON parsing (installed by `setup_install`)
