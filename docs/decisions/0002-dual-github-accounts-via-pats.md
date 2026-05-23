# 0002 - Dual GitHub Accounts via PATs

## Status
Superseded by [0005-hybrid-ssh-and-pat-auth.md](0005-hybrid-ssh-and-pat-auth.md)

## Context
The project needs to support operations across two GitHub accounts (`fortegb` and `akamlibehsafe`). We need a way to authenticate with the correct account based on which repository we're working with, without requiring users to manually switch credentials.

## Decision
Use Personal Access Tokens (PATs) stored as environment variables (`GH_TOKEN_fortegb` and `GH_TOKEN_akamlibehsafe`). Scripts automatically detect the account from the `user/repo` format or by parsing the remote URL. The appropriate PAT is selected based on the detected username.

## Alternatives considered
- **GitHub CLI authentication (`gh auth`)**: Pros: Built-in support, handles token management. Cons: Per-machine authentication, doesn't easily support multiple accounts without context switching, more complex for automation.
- **SSH keys with different hosts**: Pros: Standard Git approach. Cons: Requires SSH key management per account, more complex configuration, harder to automate API calls.
- **Manual token switching**: Pros: Simple implementation. Cons: User must manually manage tokens, error-prone, poor user experience.

## Consequences
**Positive:**
- Automatic account detection from repository name/URL
- No manual token switching required
- Works seamlessly with GitHub API for repository creation
- Simple environment variable storage
- Easy to verify with `gitak_verify_PAT`

**Negative:**
- Requires users to generate and store PATs securely
- Tokens stored in shell configuration files (security consideration)
- PATs need to be regenerated periodically if not set to "no expiration"
- Users must remember to export variables in shell config

**Risks:**
- Security: PATs in shell config files can be exposed. Mitigated by:
  - `.gitignore` excludes `PAT.md`
  - Documentation warns about secure storage
  - Recommend file permissions (600)
- Token expiration: If tokens expire, scripts fail. Mitigated by verification script and clear error messages.

## Links
- Implementation: All gitak_* scripts detect account from user/repo or remote URL
- Verification: `scripts/gitak_verify_PAT`
- Documentation: `README.md` "Prerequisites" and "Configure Personal Access Tokens" sections
