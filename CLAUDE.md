# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A personal collection of 29 reusable Ansible roles. There are no playbooks, inventories, or `ansible.cfg` at the repository root — this repo is meant to be consumed by external playbooks. Roles are located under `roles/`.

## Testing and Linting

Each role has its own test and lint configuration. Run these from within a role directory.

**Syntax check (CI equivalent):**
```bash
printf '[defaults]\nroles_path=../' > ansible.cfg
ansible-playbook tests/test.yml -i tests/inventory --syntax-check
```

**YAML lint:**
```bash
yamllint -c .yamllint .
```

**Molecule (full integration test):**
```bash
molecule test
```

**Ansible Vault** — some roles have encrypted `vars/main.yml`. Encrypt/decrypt with:
```bash
ansible-vault encrypt roles/<role>/vars/main.yml
ansible-vault decrypt roles/<role>/vars/main.yml
```
Roles using vault: `ai_tools`, `rh_dev`.

## Role Structure

All roles follow standard Ansible role layout:

```
roles/<role>/
├── tasks/main.yml              # Entry point; includes distro-specific task files
├── tasks/<distro>.yml          # Distribution-specific tasks (Fedora, Ubuntu, CentOS8, Arch, etc.)
├── defaults/main.yml           # Low-priority defaults (overridable by callers)
├── vars/main.yml               # High-priority vars; may be vault-encrypted
├── templates/                  # Jinja2 templates (.j2)
├── files/                      # Static files
├── handlers/main.yml           # Usually empty
├── meta/main.yml               # Galaxy metadata; dependencies: [] (no Galaxy deps)
├── tests/test.yml              # Test playbook targeting localhost
├── molecule/default/           # Molecule scenario
└── .yamllint                   # Per-role yamllint config (extends default, relaxed rules)
```

## Key Architectural Patterns

**Distribution awareness** — tasks are split by OS and included conditionally:
```yaml
- include_tasks: fedora.yml
  when: ansible_distribution == "Fedora"
```
Supported distributions vary per role: Fedora, Ubuntu, CentOS7/8, Arch Linux, Debian.

**Privilege escalation** — privileged tasks use `become: yes` / `become_method: sudo` consistently.

**No central inventory** — roles use Ansible facts (`ansible_distribution`, `ansible_user`, `ansible_env.HOME`) rather than group/host vars. Inventory is provided by the caller.

**Test playbooks** target `localhost` with `remote_user: root`:
```yaml
- hosts: localhost
  remote_user: root
  roles:
    - <role_name>
```

## Notable Roles

- **ai_tools** — installs a Gerrit MCP server for Claude Code integration; uses a systemd user service and a Python script (`update_claude_mcp_settings.py`) to configure Claude's MCP settings. Has a restart handler.
- **base_configs** — manages dotfiles (gitconfig, ssh_config, zshrc) via Jinja2 templates; uses Ansible synchronize module.
- **devstack** — generates OpenStack `local.conf` from templates supporting allinone/multinode/compute/network topologies.
- **i3wm** — installs a full i3 desktop environment with ~13 sub-configurations (alacritty, rofi, picom, dunst, conky, redshift, etc.).
- **openvswitch** — includes pre-built RPM binaries in `files/` for offline installation.
