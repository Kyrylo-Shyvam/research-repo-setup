#!/bin/bash
set -e

echo "=== Setting up UV environment ==="

# Get the directory of this script and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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

# Create project directory in current working directory
PROJECT_NAME="contact_graspnet"

if [ -d "$PROJECT_NAME" ]; then
    echo "Project directory $PROJECT_NAME already exists, removing..."
    rm -rf "$PROJECT_NAME"
fi

echo "Creating new project: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Copy pyproject.toml from configs
cp "$PROJECT_ROOT/configs/pyproject.toml" .

# Initialize uv project
echo "Initializing UV project..."
uv python pin 3.9

# Create virtual environment
echo "Creating virtual environment..."
uv venv

# Set up local cache directory to avoid filling home directory
CACHE_DIR="$PWD/.cache"
mkdir -p "$CACHE_DIR"
echo "Setting cache directory to: $CACHE_DIR"

# Copy requirements.txt to project
cp "$PROJECT_ROOT/configs/requirements.txt" .

# Create a basic README.md to satisfy pyproject.toml
cat > README.md << 'EOF'
# Contact GraspNet Environment

This is an automatically generated Contact GraspNet environment set up with UV.

## Activation

```bash
source .venv/bin/activate
# or
./activate.sh
```

## Directory Structure

- `.venv/` - Virtual environment
- `.cache/` - Local package cache
- `src/` - Source code (downloaded separately)
- `data/` - Datasets (downloaded separately)
- `requirements.txt` - Python dependencies

## Development

Use `./develop.sh` to enter development mode with proper PYTHONPATH setup.

## Cache Location

Package cache is stored locally in `.cache/` to avoid filling home directory.
EOF

# Install dependencies
echo "Installing dependencies..."
echo "This may take a while, especially for PyTorch with CUDA support..."

# Install packages from requirements.txt with local cache
echo "Installing all packages from requirements.txt..."
uv pip install --index-strategy unsafe-best-match --cache-dir "$CACHE_DIR" -r requirements.txt

# Verify PyTorch CUDA support
echo "Verifying PyTorch installation..."
source .venv/bin/activate
python -c "
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
echo "Cache directory: $PWD/.cache"
EOF

chmod +x activate.sh

# Create .gitignore to exclude cache and venv directories
cat > .gitignore << 'EOF'
# Virtual environment
.venv/

# Local cache directory
.cache/

# Python cache
__pycache__/
*.pyc
*.pyo

# Jupyter notebook checkpoints
.ipynb_checkpoints/
EOF

echo "✅ Environment setup completed successfully!"
echo ""
echo "To activate the environment, run:"
echo "cd contact_graspnet && source .venv/bin/activate"
echo "Or use the convenience script: cd contact_graspnet && ./activate.sh"
echo ""
echo "📁 Cache files are stored locally in: $PWD/.cache" 