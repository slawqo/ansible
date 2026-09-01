#!/usr/bin/env python3

"""Add or update an MCP server entry in a JSON settings file.

Usage:
    update_mcp_settings.py <settings_file> <name> <config_json> [servers_key]

    settings_file - path to the JSON file (e.g. ~/.claude.json, ~/.cursor/mcp.json)
    name          - server name
    config_json   - JSON object with the server configuration
    servers_key   - settings key containing server definitions (default: mcpServers)

Examples:
    update_mcp_settings.py ~/.claude.json gerrit '{"command":"/path/to/python","args":["main.py","stdio"]}'
    update_mcp_settings.py ~/.cursor/mcp.json todoist '{"type":"http","url":"https://ai.todoist.net/mcp"}'
"""

import json
import os
import sys

settings_file = os.path.expanduser(sys.argv[1])
name = sys.argv[2]
config = json.loads(sys.argv[3])
servers_key = sys.argv[4] if len(sys.argv) > 4 else "mcpServers"

try:
    with open(settings_file) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

settings.setdefault(servers_key, {})
settings[servers_key][name] = config

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
