#!/usr/bin/env python3

"""Add or update an MCP server entry in a JSON settings file.

Usage:
    update_mcp_settings.py <settings_file> <name> <config_json>

    settings_file - path to the JSON file (e.g. ~/.claude.json, ~/.cursor/mcp.json)
    name          - key under mcpServers (e.g. "gerrit", "todoist")
    config_json   - JSON object with the server configuration

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
