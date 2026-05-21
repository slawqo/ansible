# ai_tools

Installs and configures AI development tools such as MCP servers.

## Requirements

- Ansible 2.9+
- `sudo` access on the target host (for system package installation)

## Role variables

### General

| Variable | Default | Description |
|---|---|---|
| `ai_tools_install_dir` | `~/.local/share/ai_tools` | Base directory where tools are cloned and built |

### Gerrit MCP Server

| Variable | Default | Description |
|---|---|---|
| `ai_tools_gerrit_mcp_enabled` | `true` | Whether to install and configure the Gerrit MCP server |
| `ai_tools_gerrit_mcp_repo` | upstream GitHub URL | Git repository to clone |
| `ai_tools_gerrit_mcp_version` | `master` | Branch, tag, or commit to check out |
| `ai_tools_gerrit_mcp_default_gerrit_url` | `''` | Default Gerrit base URL written to `gerrit_config.json` |
| `ai_tools_gerrit_mcp_hosts` | `[]` | List of Gerrit host definitions (see below) |
| `ai_tools_gerrit_mcp_configure_claude_code` | `true` | Whether to register the server in `~/.claude.json` |

#### `ai_tools_gerrit_mcp_hosts`

A list of Gerrit instances the server can connect to. Each entry supports the following fields:

```yaml
ai_tools_gerrit_mcp_hosts:
  - name: "My Gerrit"                      # Human-readable label
    external_url: "https://review.example.com/"
    authentication:
      type: "http_basic"                   # http_basic | git_cookies | gob_curl
      username: "your-username"
      auth_token: "your-auth-token"
```

**This file contains credentials and should be encrypted with ansible-vault:**

```bash
ansible-vault encrypt roles/ai_tools/vars/main.yml
```

### Todoist MCP Server

| Variable | Default | Description |
|---|---|---|
| `ai_tools_todoist_mcp_enabled` | `true` | Whether to configure the Todoist MCP server |
| `ai_tools_todoist_mcp_url` | `https://ai.todoist.net/mcp` | URL of the hosted Todoist MCP server |

Todoist MCP is a hosted service — no local installation is required. Authentication
is handled via OAuth on first use. The role registers the server in `~/.claude.json`
so Claude Code connects to it over streamable HTTP.

### Jira (Atlassian Rovo) MCP Server

| Variable | Default | Description |
|---|---|---|
| `ai_tools_jira_mcp_enabled` | `true` | Whether to configure the Jira MCP server |
| `ai_tools_jira_mcp_url` | `https://mcp.atlassian.com/v1/mcp/authv2` | URL of the hosted Atlassian Rovo MCP server |

Jira MCP is a hosted service provided by Atlassian. It uses `npx mcp-remote` as a
bridge and authenticates via OAuth on first use. Requires Node.js v18+ and `npx`
on the target host.

## Transport modes

The Gerrit MCP server runs in **stdio** mode — Claude Code spawns it as a child process and
communicates over stdin/stdout. No network port is opened.

The Todoist MCP server is **hosted remotely** — Claude Code connects to it via streamable HTTP.

The Jira MCP server is **hosted remotely** — Claude Code connects via `mcp-remote` which
proxies the remote streamable HTTP endpoint through a local stdio process.

## Example playbook

```yaml
- name: Configure workstation
  hosts: localhost
  connection: local
  roles:
    - role: ai_tools
```

### With custom Gerrit instances

Define your hosts in a vault-encrypted vars file (e.g. `host_vars/localhost/ai_tools_vault.yml`)
and include it alongside the role:

```yaml
# host_vars/localhost/ai_tools_vault.yml  (encrypt with ansible-vault)
ai_tools_gerrit_mcp_hosts:
  - name: "Work Gerrit"
    external_url: "https://review.example.com/"
    authentication:
      type: "http_basic"
      username: "jdoe"
      auth_token: "secret-token"
  - name: "OpenStack Gerrit"
    external_url: "https://review.opendev.org/"
    authentication:
      type: "http_basic"
      username: "jdoe"
      auth_token: "another-secret-token"
```

```yaml
- name: Configure workstation
  hosts: localhost
  connection: local
  roles:
    - role: ai_tools
      vars:
        ai_tools_gerrit_mcp_default_gerrit_url: "https://review.example.com/"
```

Run with:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

### Skip Claude Code configuration

```yaml
- name: Configure workstation
  hosts: localhost
  connection: local
  roles:
    - role: ai_tools
      vars:
        ai_tools_gerrit_mcp_configure_claude_code: false
```
