#!/usr/bin/env python3

"""Add or update an MCP server entry in a JSON settings file.

Usage:
    update_mcp_settings.py <settings_file> <name> <config_json> [servers_key]

    settings_file - path to the JSON file (e.g. ~/.claude.json, ~/.cursor/mcp.json)
    name          - server name
    config_json   - JSON object with the server configuration
    servers_key   - settings key containing server definitions (default: mcpServers).
                    Zed's settings.json may contain JSONC comments and trailing commas.

Examples:
    update_mcp_settings.py ~/.claude.json gerrit '{"command":"/path/to/python","args":["main.py","stdio"]}'
    update_mcp_settings.py ~/.cursor/mcp.json todoist '{"type":"http","url":"https://ai.todoist.net/mcp"}'
"""

import json
import os
import sys


def parse_settings(text):
    """Read JSON or JSONC without treating comment markers inside strings as comments."""
    uncommented = []
    i = 0
    in_string = False
    while i < len(text):
        char = text[i]
        if in_string:
            uncommented.append(char)
            if char == "\\":
                i += 1
                if i < len(text):
                    uncommented.append(text[i])
            elif char == '"':
                in_string = False
        elif char == '"':
            in_string = True
            uncommented.append(char)
        elif text.startswith("//", i):
            i = text.find("\n", i)
            if i == -1:
                break
            uncommented.append("\n")
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end == -1:
                raise ValueError("Unterminated JSONC block comment")
            i = end + 1
        else:
            uncommented.append(char)
        i += 1

    # JSONC also permits trailing commas before closing arrays and objects.
    text = "".join(uncommented)
    cleaned = []
    i = 0
    in_string = False
    while i < len(text):
        char = text[i]
        if in_string:
            cleaned.append(char)
            if char == "\\":
                i += 1
                if i < len(text):
                    cleaned.append(text[i])
            elif char == '"':
                in_string = False
        elif char == '"':
            in_string = True
            cleaned.append(char)
        elif char == ",":
            next_index = i + 1
            while next_index < len(text) and text[next_index].isspace():
                next_index += 1
            if next_index >= len(text) or text[next_index] not in "}]":
                cleaned.append(char)
        else:
            cleaned.append(char)
        i += 1
    return json.loads("".join(cleaned))


settings_file = os.path.expanduser(sys.argv[1])
name = sys.argv[2]
config = json.loads(sys.argv[3])
servers_key = sys.argv[4] if len(sys.argv) > 4 else "mcpServers"

try:
    with open(settings_file) as f:
        settings = parse_settings(f.read())
except FileNotFoundError:
    settings = {}

settings.setdefault(servers_key, {})
settings[servers_key][name] = config

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
