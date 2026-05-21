#!/usr/bin/env python3

"""Add or update an MCP server entry in ~/.claude.json.

Usage:
    update_claude_mcp_settings.py <name> <config_json>

    name         - key under mcpServers (e.g. "gerrit", "todoist")
    config_json  - JSON object with the server configuration

Examples:
    update_claude_mcp_settings.py gerrit '{"command":"/path/to/python","args":["main.py","stdio"]}'
    update_claude_mcp_settings.py todoist '{"type":"http","url":"https://ai.todoist.net/mcp"}'
"""

import json
import os
import sys

name = sys.argv[1]
config = json.loads(sys.argv[2])
settings_file = os.path.expanduser("~/.claude.json")

try:
    with open(settings_file) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

settings.setdefault("mcpServers", {})
settings["mcpServers"][name] = config

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
