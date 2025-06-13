#!/usr/bin/env bash
set -euo pipefail
GODOT_BIN="./Godot_v4.4.1-stable_linux.x86_64"
for test_script in tests/*.gd; do
    "$GODOT_BIN" --headless --path . -s "$test_script"
done
