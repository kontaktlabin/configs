# AGENTS.md

## Project Overview
This repository is a centralized management system for personal configuration files (dotfiles) and environment setup scripts. It uses a custom orchestration tool, `bin/configs`, to manage symlinks from this repository to the host system.

## Core Tooling: `bin/configs`
All environment changes should be orchestrated through the `bin/configs` script to ensure proper tracking and idempotency.

### Common Commands
- `configs init-host`: Bootstraps a new host profile by creating `configs_map.cfg` and `readme.org`.
- `configs link <repo_path> <target_path> [map_file]`: Creates a symlink from a repo file to a host path and records it in the mapping database.
- `configs link-all [map_file]`: Links all assets defined in the provided mapping file.
- `configs unlink <target_path> [map_file]`: Removes the symlink and restores the original file from `.backup`.
- `configs unlink-all [map_file]`: Batch unlinks and restores all assets in the mapping file.
- `configs list [map_file]`: Displays the status (LINKED, UNLINKED, MISSING, etc.) of all tracked files.
- `configs update`: Performs a `git pull --rebase --autostash` to sync with the remote repository.
- `configs mkarch [usb_device] [map_file]`: Builds a custom Arch Linux installation ISO using `mkarchiso` based on profiles defined in the mapping file.
- `git <args>`: Any arguments not recognized by `configs` are forwarded directly to `git`.

## Environment Management & Gotchas
- **Hardcoded Workspace**: `bin/configs` expects the repository to be at `~/ws/i/configs`.
- **Symlink-First Workflow**: Do NOT edit files directly in `$HOME`. Edit the version in this repository, then use `configs link` to update the host.
- **Conflict Resolution**: When linking a file that already exists at the destination and is NOT a symlink, `configs link` will:
  1. Create a `.backup` of the local file.
  2. If contents differ, attempt an interactive `sdiff` merge.
- **Path Tokens**: The mapping database (`configs_map.cfg`) uses `$HOME` and `$CONFIGS_DIR` as symbolic path tokens.
- **Archiso Requirements**: `mkarch` requires `sudo` privileges and the `archiso` package to be installed.

## Git & Commit Conventions
- **Commit Format**: Standardized format is required: `<type> - <scope>: <subject>`
  - *Example*: `fix - api: resolve login endpoint error`
- **Valid Types**: `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `build`, `ci`, `test`, `revert`, `clean`.
- **Pre-commit Hooks**: Automated linting is performed on staged files:
  - **Python**: `ruff`
  - **JS/TS**: `eslint`

## Development Context
- **Workspace Structure**:
  - `~/ws/e`: External/Work projects.
  - `~/ws/i`: Internal/Personal projects.
  - `~/ws/i/configs`: This repository.
- **AI/Tooling Setup**:
  - **VSCode**: Uses a customized layout (sidebar on the right, no tabs).
  - **Aider AI**: A custom terminal profile is available in VSCode, configured to use `ollama` (`OLLAMA_API_BASE=http://localhost:11434`) with the `aider-coder` model.
  - **Custom Rules**: `.clinerules/appearance` defines visual preferences (Accent Color: `#007f7f`).

## Repository Etiquette
- Use the provided `bin/` scripts for environment manipulation.
- All configuration updates must be committed to this repository.
- Do not perform destructive git actions (e.g., force push, hard resets).
