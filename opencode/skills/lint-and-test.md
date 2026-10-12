# Skill: lint-and-test

## Description
Automates project-specific testing and linting procedures by detecting the project environment and running the appropriate tools (e.g., `tox`, `pytest`, `ruff`, `npm test`, `eslint`).

## Usage
Trigger this skill when:
- The user wants to verify their changes before committing.
- The user asks "Does my code pass tests?".
- A CI/CD pipeline fails and the user needs to reproduce it locally.
- The user wants to ensure code quality and style compliance.

## Precedence
**Project-Specific Rules Overwrite Defaults**: If the project contains explicit configurations or scripts (e.g., `.eslintrc`, `pytest.ini`, `.ruff.toml`, `Makefile`, or custom `npm` scripts) that define behavior, **always follow the project's local rules and commands** instead of the default procedures or guidelines listed below.

## Procedures

### 1. Environment Detection
Detect the project type by looking for indicator files:
- **Python (Modern)**: `pyproject.toml` $\rightarrow$ Use `tox` or `ruff`.
- **Python (Legacy/Pipenv)**: `Pipfile` or `requirements.txt` $\rightarrow$ Use `pip install` + `pytest`.
- **JavaScript/TypeScript**: `package.json` $\rightarrow$ Use `npm test` or `yarn test`.
- **Docker/Containerized**: `Dockerfile` or `docker-compose.yml` $\rightarrow$ Use `docker compose up --build`.

### 2. Execution Workflow

#### Python Projects
- **Step 1 (Linting)**: Run `ruff check .` or `black .` if available.
- **Step 2 (Testing)**: Run `tox` (preferred) or `pytest`.
- **Step 3 (Coverage)**: If configured, run `pytest --cov`.

#### Node.js Projects
- **Step 1 (Linting)**: Run `npm run lint` or `eslint .`.
- **Step 2 (Testing)**: Run `npm test`.

#### Containerized Projects
- **Step 1**: Build and run the containerized environment using `docker compose up --build`.
- **Step 2**: Run tests within the container if applicable.

## Output Format
Provide a clear summary of the results:
- [PASS] All tests and linting checks passed.
- [FAIL] Errors detected. Provide details of the first failure and suggest remediation.
- [INFO] Detected [Project Type] environment. Running [Command]...
