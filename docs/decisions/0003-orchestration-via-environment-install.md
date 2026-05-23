# 0003 - Orchestration via environment_install

## Status
Accepted

## Context
Installing and configuring a complete development environment on macOS requires multiple steps: Homebrew, Git tools, Zsh configuration, script symlinks, aliases, etc. Users need a single entry point that handles all setup in the correct order with proper dependency management.

## Decision
Create `environment_install` as an orchestration script that coordinates installation of all components in the correct order. It handles PAT configuration first, then installs dependencies (Homebrew), tools (Git, GitHub CLI, Git LFS), shell environment (Zsh, Oh My Zsh, Powerlevel10k), optional components (Cursor Desktop), and final setup (symlinks, aliases, configuration).

## Alternatives considered
- **Manual step-by-step installation**: Pros: Users understand each step, full control. Cons: Error-prone, time-consuming, easy to miss steps or do in wrong order, poor user experience.
- **Multiple independent install scripts**: Pros: Modular, can run individually. Cons: Users must know execution order, dependency management issues, no unified experience.
- **Homebrew formulae/casks**: Pros: Standard macOS approach, dependency management. Cons: Complex to create, harder to customize, doesn't handle configuration steps (symlinks, aliases, PAT setup).
- **Ansible/Chef/Puppet**: Pros: Professional infrastructure management, idempotent. Cons: Overkill for personal scripts, requires learning new tool, adds dependencies.

## Consequences
**Positive:**
- Single command installation: `./environment_install`
- Handles dependencies automatically (e.g., Homebrew before Git)
- Consistent installation experience
- Handles optional components gracefully (skippable)
- Works from zip-extracted folders (no git required initially)
- Comprehensive installation in one go

**Negative:**
- Large script with many responsibilities
- Harder to debug if something fails mid-way
- All-or-nothing approach (though components can be skipped)
- Takes 10-30 minutes to complete

**Risks:**
- Partial failure leaves system in inconsistent state. Mitigated by:
  - Each component checks for existing installations
  - Script can be re-run safely (idempotent operations)
  - Clear error messages at each step
- User interruption during long installation. Mitigated by:
  - Clear progress indicators
  - Script can be re-run (skips already-installed components)

## Links
- Implementation: `scripts/environment_install`
- Reverse operation: `scripts/environment_uninstall`
- Documentation: `README.md`
