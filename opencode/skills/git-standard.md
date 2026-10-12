# Skill: git-standard

## Description
Enforces and assists with the project's standardized git commit message format: `<type> - <scope>: <subject>`.

## Usage
Trigger this skill when:
- The user is about to commit changes.
- A commit message is reported to be invalid according to project standards.
- The user asks "How should I format my commit message?".

## Commit Format
`<type> - <scope>: <subject>`

### Valid Types
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `chore`: Changes that don't modify src or test files (e.g., updating dependencies)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `build`: Changes that affect the build system or external dependencies
- `ci`: Changes to CI configuration files and scripts
- `test`: Adding missing tests or correcting existing tests
- `revert`: Reverts a previous commit
- `clean`: Removing unused code or files

## Precedence
**Project-Specific Rules Overwrite Defaults**: If the project contains explicit configurations or scripts (e.g., `.eslintrc`, `pytest.ini`, `.ruff.toml`, `Makefile`, or custom `npm` scripts) that define behavior, **always follow the project's local rules and commands** instead of the default procedures or guidelines listed below.

## Procedures

### 1. Validate a Commit Message
- Check the provided message against the regex: `^(feat|fix|docs|chore|refactor|perf|build|ci|test|revert|clean) - .*: .*$`

### 2. Suggest a Corrected Message
- If the message is invalid, propose a version that follows the format.
- *Example*: 
  - Input: `fix login bug`
  - Suggestion: `fix - auth: resolve login bug`

## Output Format
- [VALID] The commit message follows the standard.
- [INVALID] The commit message does not follow the standard. Suggestion: `<proposed_message>`
