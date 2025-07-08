#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Fix locale issues
export LC_ALL=C

print_status "Setting up stable UV environment..."

# Clean up any existing environment
if [ -d ".venv" ]; then
    print_warning "Removing existing .venv directory..."
    rm -rf .venv
fi

# Install uv if not already installed
if ! command -v uv &> /dev/null; then
    print_status "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Source cargo env
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
else
    print_success "uv is already installed at: $(which uv)"
fi

# Check Python availability
print_status "Checking Python 3.9 availability..."
if command -v python3.9 &> /dev/null; then
    PYTHON_CMD="python3.9"
    print_success "Found Python 3.9: $(which python3.9)"
else
    print_warning "Python 3.9 not found in PATH, will let uv handle it"
    PYTHON_CMD=""
fi

# Create a new virtual environment
print_status "Creating new virtual environment..."
if [ -n "$PYTHON_CMD" ]; then
    uv venv --python $PYTHON_CMD .venv
else
    uv venv --python 3.9 .venv
fi

# Activate the environment
print_status "Activating environment..."
source .venv/bin/activate

# Copy configuration files
print_status "Setting up configuration files..."
cp configs/pyproject.toml .
cp configs/requirements_stable.txt requirements.txt

# Upgrade pip first
print_status "Upgrading pip..."
uv pip install --upgrade pip

# Install core dependencies first
print_status "Installing core dependencies..."
uv pip install numpy==1.24.3
uv pip install --extra-index-url https://download.pytorch.org/whl/cu117 torch==2.0.1+cu117 torchvision==0.15.2+cu117 torchaudio==2.0.2+cu117

# Install remaining dependencies
print_status "Installing remaining dependencies..."
uv pip install -r requirements.txt || {
    print_warning "Some dependencies failed to install. Attempting individual installation..."
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^#.*$ || "$line" =~ ^--.*$ ]]; then
            continue
        fi
        # Skip torch packages (already installed)
        if [[ "$line" =~ torch.*cu117 ]]; then
            continue
        fi
        print_status "Installing: $line"
        uv pip install "$line" || print_warning "Failed to install: $line"
    done < requirements.txt
}

# Install development dependencies
print_status "Installing development dependencies..."
uv pip install pytest black flake8 mypy

# Create activation script
cat > activate.sh << 'EOF'
#!/bin/bash
source .venv/bin/activate
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
echo "Contact GraspNet environment activated!"
echo "Python: $(which python)"
echo "Python version: $(python --version)"
echo "PyTorch version: $(python -c 'import torch; print(torch.__version__)' 2>/dev/null || echo 'Not installed')"
echo "CUDA available: $(python -c 'import torch; print(torch.cuda.is_available())' 2>/dev/null || echo 'Unknown')"
EOF

chmod +x activate.sh

# Create run script
cat > run.sh << 'EOF'
#!/bin/bash
source .venv/bin/activate
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
python "$@"
EOF

chmod +x run.sh

# Create development script
cat > develop.sh << 'EOF'
#!/bin/bash
source .venv/bin/activate
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
echo "Development environment activated!"
echo "Python: $(which python)"
echo "Python version: $(python --version)"
echo ""
echo "Available commands:"
echo "  python        - Run Python interpreter"
echo "  pytest        - Run tests"
echo "  black .       - Format code"
echo "  flake8 .      - Check code style"
echo "  mypy .        - Type check code"
echo ""
exec bash
EOF

chmod +x develop.sh

# Create a simple test script
cat > test_env.py << 'EOF'
#!/usr/bin/env python
"""Test script to verify environment setup."""

import sys
print(f"Python version: {sys.version}")

try:
    import torch
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"CUDA device: {torch.cuda.get_device_name(0)}")
except ImportError:
    print("PyTorch not installed")

try:
    import numpy as np
    print(f"NumPy version: {np.__version__}")
except ImportError:
    print("NumPy not installed")

try:
    import cv2
    print(f"OpenCV version: {cv2.__version__}")
except ImportError:
    print("OpenCV not installed")

print("\nEnvironment setup complete!")
EOF

chmod +x test_env.py

print_success "Environment setup complete!"
print_status "To activate the environment, run: source activate.sh"
print_status "To test the environment, run: ./test_env.py"