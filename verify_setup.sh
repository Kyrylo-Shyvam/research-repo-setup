#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
    echo -e "${NC}"
}

print_header "Contact GraspNet Setup Verification"

# Check if project directory exists
PROJECT_DIR="$HOME/contact_graspnet"
if [ -d "$PROJECT_DIR" ]; then
    print_success "Project directory exists: $PROJECT_DIR"
    cd "$PROJECT_DIR"
else
    print_error "Project directory not found: $PROJECT_DIR"
    exit 1
fi

# Check Python installation
print_status "Checking Python installation..."
if command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    print_success "Python found: $PYTHON_VERSION"
else
    print_error "Python not found"
fi

# Check pyenv
print_status "Checking pyenv..."
if command -v pyenv &> /dev/null; then
    PYENV_VERSION=$(pyenv version)
    print_success "Pyenv found: $PYENV_VERSION"
else
    print_error "Pyenv not found"
fi

# Check UV
print_status "Checking UV..."
export PATH="$HOME/.cargo/bin:$PATH"
if command -v uv &> /dev/null; then
    UV_VERSION=$(uv --version)
    print_success "UV found: $UV_VERSION"
else
    print_error "UV not found"
fi

# Check virtual environment
print_status "Checking virtual environment..."
if [ -d ".venv" ]; then
    print_success "Virtual environment found"
    
    # Activate and test
    source .venv/bin/activate
    
    print_status "Testing PyTorch installation..."
    python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA version: {torch.version.cuda}')
    print(f'GPU count: {torch.cuda.device_count()}')
    print('✓ PyTorch with CUDA is working!')
else:
    print('⚠ PyTorch installed but CUDA not available')
" 2>/dev/null && print_success "PyTorch test passed" || print_error "PyTorch test failed"

    print_status "Testing other key packages..."
    python -c "
import numpy as np
import matplotlib.pyplot as plt
import cv2
import open3d as o3d
import trimesh
print('✓ All key packages imported successfully!')
" 2>/dev/null && print_success "Package import test passed" || print_error "Some packages failed to import"

else
    print_error "Virtual environment not found"
fi

# Check for source code
print_status "Checking source code..."
if [ -d "src" ]; then
    print_success "Source code directory found"
    cd src
    echo "   Repository: $(git remote get-url origin 2>/dev/null || echo 'Unknown')"
    echo "   Branch: $(git branch --show-current 2>/dev/null || echo 'Unknown')"
    echo "   Files: $(find . -name "*.py" | wc -l) Python files"
    cd ..
else
    print_error "Source code directory not found"
fi

# Check for dataset
print_status "Checking dataset..."
if [ -d "data/dataset" ]; then
    print_success "Dataset directory found"
    DATASET_SIZE=$(du -sh data/dataset 2>/dev/null | cut -f1)
    DATASET_FILES=$(find data/dataset -type f | wc -l)
    echo "   Size: $DATASET_SIZE"
    echo "   Files: $DATASET_FILES"
else
    print_error "Dataset directory not found"
fi

# Check convenience scripts
print_status "Checking convenience scripts..."
SCRIPTS=("activate.sh" "run.sh" "develop.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        print_success "$script found"
    else
        print_error "$script not found"
    fi
done

print_header "Verification Complete"

echo ""
echo "If all checks passed, your Contact GraspNet environment is ready!"
echo ""
echo "To get started:"
echo "  cd ~/contact_graspnet"
echo "  ./develop.sh" 