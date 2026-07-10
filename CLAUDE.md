# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Emacs configuration layered on top of [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d). The base (`~/.emacs.d/`) is upstream-managed; the user config lives here (`~/emacs/`).

## Load order

```
~/.emacs.d/pre-early-init.el   ← upstream
~/.emacs.d/early-init.el       ← upstream
~/emacs/pre-init.el            ← bootstraps straight.el
~/.emacs.d/init.el             ← upstream base; loads pre-init.el then post-init.el
~/emacs/post-init.el           ← primary user config; loads org.el and completion.el
~/emacs/org.el                 ← all org-mode config
~/emacs/completion.el          ← vertico, corfu, consult, embark, cape
```

`init.el` and `early-init.el` in this repo are upstream copies — prefer editing `post-init.el` for user changes.

## Package management

- **straight.el** (bootstrapped in `pre-init.el`) with `straight-use-package-by-default t`
- `use-package-always-ensure nil` — straight handles fetching
- `compile-angel` auto-byte-compiles `.el` files on load and save

## Architecture

| File | Role |
|---|---|
| `pre-init.el` | Bootstraps straight.el only |
| `post-init.el` | Evil, themes, magit, leader maps, misc packages |
| `org.el` | Org-mode, org-appear, org-superstar, olivetti, svg-tag-mode, xenops |
| `completion.el` | Vertico + orderless + marginalia + embark + consult + corfu + cape + prescient |

## Key packages & conventions

- **Evil** with `jk` escape sequence; `,` as leader, `SPC` as local leader
- **general.el** for all keybindings — use `(leader :states 'normal ...)` pattern
- **Clipboard**: system clipboard via `wl-copy`/`wl-paste` operators (X11 `"+` register is unreliable in this setup)
- **Org files**: `~/org/` directory; agenda from `~/org/agenda`; captures to `~/org/refile.org` and `~/org/log.org`
- **Theme**: doom-nord + doom-modeline + nerd-icons (run `M-x nerd-icons-install-fonts` on fresh install)
- **Font**: SauceCodePro Nerd Font Medium 14

## Key leader bindings

| Binding | Command |
|---|---|
| `,gg` | `magit-status` |
| `,lg` | `consult-ripgrep` |
| `,lf` | `consult-fd` |
| `,lr` | `consult-recent-file` |
| `,la` | `consult-org-agenda` |
| `,lh` | `consult-org-heading` (org-mode only) |
| `,dd` | `define-word` (via dico CLI) |
| `,e` | `eval-last-sexp` |
| `,w` | `save-buffer` |
| `C-c r` | Reload `post-init.el` |

## Known issues / TODOs

- Config split between `~/.emacs.d/` and `~/emacs/` is intentionally messy — `pre-init.el` and `pre-early-init.el` are duplicated across both. The README documents the intent to consolidate.
- Windows support is not yet implemented.
