# iTerm2 profile export

This folder contains a **bundled iTerm2 settings export** used by `environment_install`:

- **File:** `iTerm2 State.itermexport`
- **Format:** iTerm2 native export (gzip-compressed); not hand-edited in the repo.

During install, the script:

1. Installs **iTerm2** via Homebrew (`brew install --cask iterm2`) if it is not already in `/Applications`.
2. Optionally opens this file in iTerm2 so you can **confirm the import** in the app (double-click or File → Import).

You can import later manually:

```bash
open -a iTerm "/path/to/gitscripts/config/iterm2/iTerm2 State.itermexport"
```

Or copy the file path from Finder and use **iTerm2 → Settings → General → Load settings from a custom folder / Import**.
