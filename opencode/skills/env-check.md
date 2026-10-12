# Skill: env-check

## Description
Performs a comprehensive diagnostic check of the current development environment to ensure all necessary dependencies and services are running.

## Usage
Trigger this skill when:
- Starting work on a new project.
- Encountering "command not found" or "module not found" errors.
- Encountering connection errors to databases or services.
- When the user asks "Is my environment ready?".

## Precedence
**Project-Specific Rules Overwrite Defaults**: If the project contains explicit configurations or scripts (e.g., `.eslintrc`, `pytest.ini`, `.ruff.toml`, `Makefile`, or custom `npm` scripts) that define behavior, **always follow the project's local rules and commands** instead of the default procedures or guidelines listed below.

## Procedures

### 1. Python Environment Check
- Check if a virtual environment is active (`VIRTUAL_ENV` env var).
- If active, verify that installed packages match `requirements.txt` or `pyproject.toml` using `pip freeze` vs `grep` or similar.
- Check if `python --version` matches the expected version in project docs.

### 2. Node.js Environment Check
- Check for the existence of `node_modules/`.
- Run `npm list --depth=0` to check for missing dependencies.
- Verify `node --version`.

### 3. Docker & Containerization Check
- Check if the Docker daemon is running (`docker info`).
- Check if `docker-compose` or `docker compose` is available.
- If a `docker-compose.yml` exists, check the status of the services (`docker compose ps`).

### 4. Database/Service Check
- If a database is specified in the project, attempt a connection test (e.g., `pg_isready` for Postgres).

## Output Format
Provide a clear summary:
- [OK] Service/Dependency Name
- [MISSING] Service/Dependency Name
- [ERROR] Brief description of error
