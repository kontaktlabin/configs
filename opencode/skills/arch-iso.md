# Skill: arch-iso

## Description
Provides a high-level interface for creating custom Arch Linux installation ISOs using the `configs mkarch` command. This skill leverages the existing orchestration system to build specialized, reproducible Arch Linux environments based on defined profiles.

## Usage
Trigger this skill when:
- The user wants to build a new Arch Linux ISO.
- The user needs to update an existing ISO profile.
- The user wants to create a specialized environment for a specific hardware setup or development workflow.

## Precedence
**Project-Specific Rules Overwrite Defaults**: If the project contains explicit configurations or scripts (e.g., `.eslintrc`, `pytest.ini`, `.ruff.toml`, `Makefile`, or custom `npm` scripts) that define behavior, **always follow the project's local rules and commands** instead of the default procedures or guidelines listed below.

## Procedures

### 1. Identify Profile and Target
- Determine which mapping file (`configs_map.cfg` or a custom one) defines the desired Arch Linux profile.
- Identify the target USB device if specified (defaulting to a local build if no device is provided).

### 2. Execute Build
- Run the command: `configs mkarch [usb_device] [map_file]`
- **Note**: This command requires `sudo` privileges and the `archiso` package must be installed on the host system.

### 3. Verify Build
- Monitor the build process for errors.
- Once complete, verify the ISO or the flashed USB device is usable.

## Output Format
- [STARTING] Building Arch Linux ISO using profile: `<profile_name>`
- [SUCCESS] ISO build complete. Location: `<output_path>` or Flashed to: `<device>`
- [FAILURE] Error during ISO build. Review `mkarchiso` logs for details.
- [WARNING] Requires `sudo` privileges. Please ensure user has authorization.
