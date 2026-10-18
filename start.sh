#!/usr/bin/env bash
# ====================================================================
# Whisper Auto Transcriber - Universal Unix Launcher (macOS / Linux)
# ====================================================================
set -e
cd "$(dirname "$0")"

OS_NAME="$(uname -s)"
if [[ "$OS_NAME" == "Darwin" ]]; then
    if [[ -f "./start_mac.command" ]]; then
        exec bash ./start_mac.command "$@"
    fi
else
    if [[ -f "./start_linux.sh" ]]; then
        exec bash ./start_linux.sh "$@"
    fi
fi
