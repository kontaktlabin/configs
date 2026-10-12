# Skill: doc-sync

## Description
Automates the maintenance of project documentation to prevent documentation drift.

## Usage
Trigger this skill when:
- Dependencies have been added or removed.
- The directory structure has significantly changed.
- The user asks "Is the documentation up to date?".

## Precedence
**Project-Specific Rules Overwrite Defaults**: If the project contains explicit configurations or scripts (e.g., `.eslintrc`, `pytest.ini`, `.ruff.toml`, `Makefile`, or custom `npm` scripts) that define behavior, **always follow the project's local rules and commands** instead of the default procedures or guidelines listed below.

## Procedures

### 1. Dependency Synchronization
- Parse `pyproject.toml`, `requirements.txt`, `package.json`, or `go.mod`.
- Identify the "Requirements" or "Installation" section in the project's `README.md`.
- Update the list of dependencies to reflect the current state of the project.

### 2. Architecture Mapping
- Scan the project structure to identify key directories (e.g., `src/`, `apps/`, `backend/`, `frontend/`).
- If the project contains a Mermaid.js diagram or a text-based architecture description, update the relationships and component list based on the current file structure.

### 3. README Verification
- Check if the `README.md` contains accurate setup commands (e.g., matches `npm run dev` or `make install`).

## Output Format
Provide a summary of changes:
- [UPDATED] Section name in `README.md`
- [SYNCED] Dependency list (added/removed)
- [DETECTED] New architectural components
