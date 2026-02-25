#!/bin/bash

# --- Poetry & Environment Auto-Manager (macOS) ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

PYTHON_CMD="python3"

# 1. Check if Poetry is installed
if ! command -v poetry &> /dev/null && ! $PYTHON_CMD -m poetry --version &> /dev/null; then
    echo "Poetry not found. Attempting to install via pip..."
    $PYTHON_CMD -m pip install poetry
    if [ $? -ne 0 ]; then
        echo "Failed to install Poetry via pip. Please install it manually: https://python-poetry.org/docs/#installation"
        exit 1
    fi
fi

# 2. Ensure dependencies are installed (virtual environment)
if [ ! -d ".venv" ] && [ ! -f "poetry.lock" ]; then
    echo "Setting up virtual environment and installing dependencies..."
    $PYTHON_CMD -m poetry install
fi

# 3. Finally, run the sync engine
echo "Launching myWhoosh2Garmin Monitor via Poetry..."
$PYTHON_CMD -m poetry run python3 myWhoosh2Garmin.py --monitor
