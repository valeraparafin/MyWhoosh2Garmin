#!/bin/bash

# --- Poetry & Environment Auto-Manager (macOS) ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# 0. Find the best Python version (prefer modern ones)
PYTHON_CMD=""
for cmd in "python3.12" "python3.11" "/usr/local/bin/python3" "/opt/homebrew/bin/python3" "python3"; do
    if command -v $cmd &> /dev/null; then
        # Check version
        v=$($cmd -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
        if [ "$(printf '%s\n' "3.11" "$v" | sort -V | head -n1)" = "3.11" ]; then
            PYTHON_CMD=$cmd
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "ERROR: Project requires Python 3.11 or higher."
    echo "Current system Python ($(python3 --version)) is too old."
    echo "Please install Python 3.12 via Homebrew:"
    echo "  brew install python@3.12"
    exit 1
fi

echo "Using $PYTHON_CMD ($($PYTHON_CMD --version))"

# 1. Check if Poetry is installed
POETRY_CMD=""
if command -v poetry &> /dev/null; then
    POETRY_CMD="poetry"
elif $PYTHON_CMD -m poetry --version &> /dev/null; then
    POETRY_CMD="$PYTHON_CMD -m poetry"
fi

if [ -z "$POETRY_CMD" ]; then
    echo "Poetry not found."
    if command -v brew &> /dev/null; then
        echo "Attempting to install Poetry via Homebrew (recommended for macOS)..."
        brew install poetry
        POETRY_CMD="poetry"
    else
        echo "Attempting to install via pip..."
        $PYTHON_CMD -m pip install poetry
        POETRY_CMD="$PYTHON_CMD -m poetry"
    fi
    
    if [ $? -ne 0 ]; then
        echo "------------------------------------------------"
        echo "ERROR: Failed to install Poetry automatically."
        echo "Please install it manually by running:"
        echo "  brew install poetry"
        echo "------------------------------------------------"
        exit 1
    fi
fi

# 1.5 Tell Poetry to use our preferred Python
$POETRY_CMD env use $PYTHON_CMD

# 2. Ensure dependencies are installed (virtual environment)
# Force install if env is missing or version mismatch
echo "Ensuring virtual environment and dependencies are up to date..."
$POETRY_CMD install

# 3. Finally, run the sync engine
echo "Launching myWhoosh2Garmin Monitor via Poetry..."
$POETRY_CMD run python myWhoosh2Garmin.py --monitor
