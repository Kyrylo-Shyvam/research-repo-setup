#!/bin/bash
set -e

echo "=== Setting up UV environment ==="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Initialize pyenv if available
if command -v pyenv &> /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Install uv if not present
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Add to bashrc if not already there
    if ! grep -q 'cargo/bin' ~/.bashrc; then
        echo '' >> ~/.bashrc
        echo '# UV/Cargo PATH' >> ~/.bashrc
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    fi
    
    echo "UV installed successfully"
else
    echo "UV is already installed"
fi

# Ensure we have uv in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Create project directory
PROJECT_NAME="contact_graspnet"
cd "$HOME"

if [ -d "$PROJECT_NAME" ]; then
    echo "Project directory $PROJECT_NAME already exists, removing..."
    rm -rf "$PROJECT_NAME"
fi

echo "Creating new project: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create pyproject.toml
cat > pyproject.toml << 'EOF'
[project]
name = "contact-graspnet"
version = "0.1.0"
description = "Contact GraspNet PyTorch implementation"
requires-python = ">=3.9"
dependencies = []

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.uv]
dev-dependencies = []
EOF

# Initialize uv project
echo "Initializing UV project..."
uv python pin 3.9

# Copy requirements.txt to project
cp "$PROJECT_DIR/configs/requirements.txt" .

# Install dependencies
echo "Installing dependencies..."
echo "This may take a while, especially for PyTorch with CUDA support..."

# Install packages in chunks to handle potential memory issues
echo "Installing PyTorch packages first..."
uv add torch==2.0.1+cu117 torchvision==0.15.2+cu117 torchaudio==2.0.2+cu117 --extra-index-url https://download.pytorch.org/whl/cu117

# Install remaining packages
echo "Installing remaining packages..."
uv pip install -r requirements.txt

# Verify PyTorch CUDA support
echo "Verifying PyTorch installation..."
uv run python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA version: {torch.version.cuda}')
    print(f'GPU count: {torch.cuda.device_count()}')
else:
    print('Warning: CUDA not available!')
"

# Create activation script
cat > activate.sh << 'EOF'
#!/bin/bash
# Activate the contact_graspnet environment
source .venv/bin/activate
export PYTHONPATH="$PWD:$PYTHONPATH"
echo "Contact GraspNet environment activated!"
echo "Python: $(which python)"
echo "Project directory: $PWD"
EOF

chmod +x activate.sh

echo "✅ Environment setup completed successfully!"
echo ""
echo "To activate the environment, run:"
echo "cd ~/contact_graspnet && source .venv/bin/activate"
echo "Or use the convenience script: cd ~/contact_graspnet && ./activate.sh" 