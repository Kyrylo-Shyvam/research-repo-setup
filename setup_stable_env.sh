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

# Fix locale issues
export LC_ALL=C

print_status "Setting up stable UV environment..."

# Install uv if not already installed
if ! command -v uv &> /dev/null; then
    print_status "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
else
    print_success "uv is already installed"
fi

# Create a new virtual environment
print_status "Creating new virtual environment..."
uv venv --python 3.9 .venv

# Activate the environment
print_status "Activating environment..."
source .venv/bin/activate

# Copy configuration files
print_status "Setting up configuration files..."
cp configs/pyproject.toml .
cp configs/requirements.txt .

# Install dependencies using uv
print_status "Installing dependencies with uv..."
uv pip install -r requirements.txt

# Create activation script
cat > activate.sh << 'EOF'
#!/bin/bash
source .venv/bin/activate
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
echo "Contact GraspNet environment activated!"
echo "Python: $(which python)"
echo "Python version: $(python --version)"
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

print_success "Environment setup complete!"
print_status "To activate the environment, run: source activate.sh"