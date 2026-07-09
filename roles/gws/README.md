# gws

Installs and configures the [Google Workspace CLI](https://github.com/googleworkspace/cli)
(`gws`) — a unified command-line tool for Gmail, Drive, Calendar, Sheets, Docs, and
other Google Workspace APIs. The role also deploys bundled agent skills for
**Claude Code** and **Cursor**.

> This follows the [Red Hat AI Skills Workshop — GWS](https://redhat-ai-analysis.pages.redhat.com/ai-skills-workshop/06-gws/)
> pattern: install the CLI, configure OAuth, install skills, and use helpers such as
> `gws gmail +triage` to read email from the terminal.

## Requirements

- Ansible 2.9+
- `sudo` access on the target host (for system package installation)
- Node.js 18+ (installed automatically when `gws_install_method: npm`)
- A Google Cloud project with OAuth **Desktop app** credentials

## Role variables

### Installation

| Variable | Default | Description |
|---|---|---|
| `gws_version` | `0.22.5` | Version of `@googleworkspace/cli` to install |
| `gws_install_method` | `npm` | `npm` (global npm package) or `binary` (GitHub release) |
| `gws_package` | `@googleworkspace/cli` | npm package name |
| `gws_binary_install_dir` | `~/.local/bin` | Destination for the binary when `gws_install_method: binary`; also receives a symlink for npm installs |
| `gws_bin` | `''` | Full path to the `gws` executable; auto-detected when empty |
| `gws_config_dir` | `~/.config/gws` | gws configuration directory |

### OAuth

| Variable | Default | Description |
|---|---|---|
| `gws_oauth_enabled` | `true` | Deploy `client_secret.json` to `gws_config_dir` |
| `gws_oauth_client_id` | `''` | OAuth client ID (Desktop app) |
| `gws_oauth_client_secret` | `''` | OAuth client secret |
| `gws_oauth_project_id` | `''` | GCP project ID |
| `gws_oauth_client_secret_content` | `{}` | Full JSON content for `client_secret.json` (overrides fields above) |
| `gws_auth_scopes` | `gmail,drive,calendar,sheets,docs` | Documented scopes for manual `gws auth login` |
| `gws_credentials_file` | `''` | Path for pre-exported credentials (headless/CI) |
| `gws_credentials_content` | `{}` | JSON credentials written to `gws_credentials_file` |
| `gws_env` | `{}` | Extra environment variables written to `gws_config_dir/.env` |

**Store OAuth secrets in a vault-encrypted vars file:**

```bash
ansible-vault encrypt roles/gws/vars/main.yml
```

### Skills

| Variable | Default | Description |
|---|---|---|
| `gws_skills_enabled` | `true` | Install upstream gws skills via `npx skills add` (100+ from googleworkspace/cli) |
| `gws_skills_repo` | upstream GitHub URL | Upstream skills repository |
| `gws_skills_agents` | `[claude-code, cursor]` | AI tools that receive upstream skills |
| `gws_skills_install_all` | `true` | Install all upstream skills (`--all`) |
| `gws_skills_list` | `[]` | Specific upstream skill names when `gws_skills_install_all: false` |
| `gws_custom_skills_enabled` | `true` | Deploy custom skills from this role |
| `gws_custom_skills` | `[gws-overview, gws-gmail-search]` | Custom skill names to deploy |

#### Upstream skills (from googleworkspace/cli)

Already included when `gws_skills_enabled: true`. Relevant Gmail skills:

| Skill | What it covers |
|-------|----------------|
| `gws-gmail` | Full Gmail API |
| `gws-gmail-triage` | Inbox summary; supports `--query` |
| `gws-gmail-read` | Read message body/headers |
| `gws-gmail-send` / `reply` / `forward` | Outbound mail |
| `gws-shared` | Auth, flags, output formats |
| `recipe-forward-labeled-emails` | Find by label and forward |

#### Custom skills (from this role)

Fill gaps upstream does not document as standalone workflows:

| Skill | What it covers |
|-------|----------------|
| `gws-overview` | Entry point — how Cursor should use gws and upstream skills |
| `gws-gmail-search` | Gmail query cheat sheet; search by keyword/sender/subject; **sent in last X days with label Y** |

Example query the custom skill teaches:

```bash
gws gmail +triage --query 'in:sent label:work newer_than:14d' --max 100 --labels
```

## Where configuration is written

| Component | Path |
|-----------|------|
| OAuth client secret | `~/.config/gws/client_secret.json` |
| Environment overrides | `~/.config/gws/.env` |
| Agent skills (Claude Code) | `~/.claude/skills/gws-*/SKILL.md` + custom `gws-overview`, `gws-gmail-search` |
| Agent skills (Cursor) | `~/.cursor/skills/gws-*/SKILL.md` + custom `gws-overview`, `gws-gmail-search` |

## Example playbook

```yaml
- name: Configure Google Workspace CLI
  hosts: localhost
  connection: local
  roles:
    - role: gws
```

### With vault-encrypted OAuth credentials

```yaml
# host_vars/localhost/gws_vault.yml  (encrypt with ansible-vault)
gws_oauth_client_id: "123456789.apps.googleusercontent.com"
gws_oauth_client_secret: "GOCSPX-..."
gws_oauth_project_id: "my-gcp-project"
```

```yaml
- name: Configure Google Workspace CLI
  hosts: localhost
  connection: local
  roles:
    - role: gws
      vars_files:
        - host_vars/localhost/gws_vault.yml
```

Run with:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

## Post-install: authenticate

OAuth login is interactive and cannot be fully automated by Ansible. After the role
runs, complete authentication once:

```bash
# Option A: automated setup (requires gcloud CLI)
gws auth setup
gws auth login -s gmail,drive,calendar

# Option B: manual setup (client_secret.json already deployed by this role)
gws auth login -s gmail,drive,calendar
```

For unverified OAuth apps in testing mode, Google limits scopes to ~25. Use `-s` to
select only the services you need rather than the full `recommended` preset.

### Verify

```bash
gws auth status
gws gmail +triage          # unread inbox summary
gws calendar +agenda       # today's events
```

## Using gws for email (workshop examples)

```bash
# Inbox triage
gws gmail +triage

# Send email
gws gmail +send --to alice@example.com --subject "Hello" --body "Hi there"

# List recent messages (Discovery API)
gws gmail users messages list --params '{"userId": "me", "maxResults": 10}'
```

Cursor learns to use gws via the installed **agent skills** and shell commands —
there is no built-in MCP server in `gws`.

## GCP setup checklist

If you do not use `gws auth setup`, configure OAuth manually in Google Cloud Console:

1. Create a GCP project (or reuse an existing one)
2. Enable APIs: Gmail, Drive, Calendar, Sheets, Docs (as needed)
3. Configure OAuth consent screen (External, testing mode is fine)
4. Add yourself as a **Test user**
5. Create OAuth client ID → **Desktop app**
6. Download the JSON and either paste into `gws_oauth_client_secret_content` or set
   `gws_oauth_client_id`, `gws_oauth_client_secret`, and `gws_oauth_project_id`

## Testing

```bash
cd roles/gws
printf '[defaults]\nroles_path=../' > ansible.cfg
ansible-playbook tests/test.yml -i tests/inventory --syntax-check
yamllint -c .yamllint .
```
