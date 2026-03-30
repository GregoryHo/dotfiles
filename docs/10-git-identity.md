# Git Identity Management

Directory-based identity routing using `includeIf` separates public GitHub
identity (tracked) from private work identities (gitignored).

## Why

You commit to GitHub with your personal email and signing key, but to a work
GitLab with a corporate email and different key. Hard-coding either identity in
`.gitconfig` means the wrong name appears on some commits. Switching manually
is error-prone.

The solution: Git's `includeIf` directive automatically applies the right
identity based on which directory the repo lives in.

## How It Works

### Identity Routing

```
git/.gitconfig
│
├── [includeIf "gitdir:~/GitHub/"]
│   └──▶ git/.gitconfig-github     ◀── TRACKED (public info)
│        ┌──────────────────────────────────┐
│        │ [user]                            │
│        │   name = GregoryHo               │
│        │   email = greghojob@gmail.com    │
│        │   signingkey = ~/.ssh/github.pub │
│        │ [gpg]                            │
│        │   format = ssh                   │
│        │ [commit]                         │
│        │   gpgsign = true                 │
│        └──────────────────────────────────┘
│
├── [include]
│   └──▶ ~/.gitconfig.local         ◀── GITIGNORED
│        ┌──────────────────────────────────┐
│        │ [includeIf "gitdir:~/work/"]     │
│        │   path = ~/.gitconfig-work       │
│        └──────────────────────────────────┘
│                    │
│                    └──▶ ~/.gitconfig-work  ◀── GITIGNORED
│                         ┌──────────────────────────────┐
│                         │ [user]                        │
│                         │   name = Greg Ho              │
│                         │   email = greg@company.com   │
│                         │   signingkey = ~/.ssh/work   │
│                         └──────────────────────────────┘
│
└── (base settings: pager, grep, aliases, etc.)
```

### What's Tracked vs Gitignored

```
TRACKED (safe to push)                GITIGNORED (private)
──────────────────────                ────────────────────
git/.gitconfig                        ~/.gitconfig.local
  └── base settings                     └── work includeIf directives
  └── GitHub includeIf

git/.gitconfig-github                 ~/.gitconfig-work (etc.)
  └── personal name/email               └── corporate identity
  └── SSH signing key path               └── different signing key
  └── gpg format = ssh
```

The key insight: GitHub identity is **public information** (it's on every
commit you push to GitHub anyway), so it's safe to track. Work identities
contain corporate directory paths and emails that shouldn't be in a public repo.

### Commit Signing

All commits are signed with SSH keys:

```ini
# git/.gitconfig-github
[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers

[commit]
    gpgsign = true
```

This uses SSH keys (not GPG) for signing — simpler setup, same `Verified` badge
on GitHub.

### Delta Pager

Git diffs use [delta](https://github.com/dandavella/delta) for syntax-highlighted output:

```ini
# git/.gitconfig
[pager]
    diff = delta
    log = delta
    reflog = delta
    show = delta

[delta]
    true-color = always
    theme = Monokai Extended
    plus-style = "syntax #012800"     # Green background for additions
    minus-style = "syntax #340001"    # Red background for deletions
```

### Grep Configuration

```ini
[grep]
    break = true
    heading = true
    lineNumber = true
    extendedRegexp = true
```

Groups results by file with headings, line numbers, and extended regex — similar
to ripgrep's default output style.

## Key Files

| File | Role |
|------|------|
| `git/.gitconfig` | Base config with delta, grep, includeIf routing |
| `git/.gitconfig-github` | Public GitHub identity (tracked) |
| `~/.gitconfig.local` | Private work identity routing (gitignored) |

## See Also

- [03-config-override-pattern.md](03-config-override-pattern.md) — the general override pattern
- [13-safety-defaults.md](13-safety-defaults.md) — commit signing enforcement
