#!/usr/bin/env python3

import json
import os
import sys

project_dir = sys.argv[1]
settings_file = os.path.expanduser("~/.claude.json")

try:
    with open(settings_file) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

settings.setdefault("mcpServers", {})

settings["mcpServers"]["gerrit"] = {
    "command": os.path.join(project_dir, ".venv", "bin", "python"),
    "args": [
        os.path.join(project_dir, "gerrit_mcp_server", "main.py"),
        "stdio",
    ],
    "env": {
        "PYTHONPATH": project_dir + "/",
    },
}

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
