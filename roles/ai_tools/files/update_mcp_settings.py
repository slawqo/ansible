#!/usr/bin/env python3

"""Add, update, or remove an MCP server entry in a JSON settings file.

Usage:
    update_mcp_settings.py <settings_file> <name> <config_json> [servers_key]
    update_mcp_settings.py --remove <settings_file> <name> [servers_key]

    settings_file - path to the JSON file (e.g. ~/.claude.json, ~/.cursor/mcp.json)
    name          - server name
    config_json   - JSON object with the server configuration
    servers_key   - dotted path to the key containing server definitions
                    (default: mcpServers). Dots nest, so OpenCode v2 uses
                    mcp.servers. Zed's settings.json may contain JSONC comments
                    and trailing commas.

Examples:
    update_mcp_settings.py ~/.claude.json gerrit '{"command":"/path/to/python","args":["main.py","stdio"]}'
    update_mcp_settings.py ~/.cursor/mcp.json todoist '{"type":"http","url":"https://ai.todoist.net/mcp"}'
    update_mcp_settings.py --remove ~/.config/opencode/opencode.json gerrit mcp
"""

import argparse
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


def resolve_container(settings, servers_key, create=False):
    """Return the dict at the dotted servers_key path, or None when absent."""
    container = settings
    for part in servers_key.split("."):
        if create:
            container = container.setdefault(part, {})
        elif isinstance(container, dict) and part in container:
            container = container[part]
        else:
            return None
    return container


parser = argparse.ArgumentParser(
    description="Add, update, or remove an MCP server entry in a JSON settings file.")
parser.add_argument(
    "--remove",
    action="store_true",
    help="remove the server entry instead of adding or updating it")
parser.add_argument("settings_file")
parser.add_argument("name")
parser.add_argument(
    "config_json", nargs="?",
    help="JSON object with the server configuration")
parser.add_argument(
    "servers_key", nargs="?", default="mcpServers",
    help="dotted path to the key containing server definitions (default: mcpServers)")
args = parser.parse_args()

# In --remove mode no config is passed, so a third positional is the servers_key.
if args.remove and args.config_json is not None:
    if args.servers_key != "mcpServers":
        parser.error("--remove takes <settings_file> <name> [servers_key]")
    args.servers_key = args.config_json
    args.config_json = None

settings_file = os.path.expanduser(args.settings_file)

try:
    with open(settings_file) as f:
        settings = parse_settings(f.read())
except FileNotFoundError:
    if args.remove:
        sys.exit(0)
    settings = {}

if args.remove:
    container = resolve_container(settings, args.servers_key)
    if container is None or args.name not in container:
        sys.exit(0)
    del container[args.name]
else:
    container = resolve_container(settings, args.servers_key, create=True)
    container[args.name] = json.loads(args.config_json)

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
