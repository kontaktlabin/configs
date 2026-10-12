# Skill: dotfiles

## Description
Manages host configuration files (dotfiles) using the `configs` orchestration tool. This ensures that all configuration changes are tracked and can be easily replicated across different machines.

## Usage
Trigger this skill when:
- The user wants to link a new configuration file to their home directory.
- The user wants to apply all configured dotfiles to the current host.
- The user wants to check the status of their currently linked dotfiles.
- The user wants to remove a previously linked configuration file.

## Precedence
**Project-Specific Rules Overwrite Defaults**: If the project contains explicit configurations or scripts (e.g., `.eslintrc`, `pytest.ini`, `.ruff.toml`, `Makefile`, or custom `npm` scripts) that define behavior, **always follow the project's local rules and commands** instead of the default procedures or guidelines listed below.

## Procedures

### 1. Link a Single File
- Identify the source file in the `configs` repository.
- Identify the target path in the host system (e.g., `$HOME/.bashrc`).
- Execute: `configs link <source_path> <target_path>`

### 2. Link All Assets
- If a mapping file (`configs_map.cfg` or a custom one) is available, execute: `configs link-all [map_file]`

### 3. Check Status
- Use `configs list` to show the current state of all tracked files (LINKED, UNLINKED, MISSING).

### 4. Unlink/Remove a File
- If a file needs to be unlinked and restored to its backup: `configs unlink <target_path>`

## Output Format
Provide a summary of the action performed:
- [SUCCESS] Action description (e.g., Linked .bashrc)
- [FAILURE] Error message from `configs`
- [STATUS] Summary from `configs list`
