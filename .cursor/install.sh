#!/usr/bin/env bash
# Idempotent bootstrap for the 99-ML-Learning-Projects notebooks.
# Creates a project-local virtualenv and installs the pinned ML stack.
set -euo pipefail

cd "$(dirname "$0")/.."

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR=".venv"

# The default Cloud Agent image ships Python 3.12 without the venv/ensurepip
# module. Install it (idempotently) so we can build a project-local virtualenv.
if ! "${PYTHON_BIN}" -c "import ensurepip" >/dev/null 2>&1; then
  echo "Installing python3-venv (ensurepip) system package"
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends python3-venv python3.12-venv
fi

if [ ! -x "${VENV_DIR}/bin/python" ]; then
  echo "Creating virtualenv in ${VENV_DIR}"
  "${PYTHON_BIN}" -m venv "${VENV_DIR}"
fi

# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"

python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# Register the venv as a Jupyter kernel so notebooks run against these deps.
python -m ipykernel install --user --name 99-ml --display-name "Python (99-ML)"

echo "Environment ready. Activate with: source ${VENV_DIR}/bin/activate"
