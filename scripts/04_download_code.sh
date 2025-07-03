#!/bin/bash
set -e

echo "=== Downloading Code from GitHub ==="

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set"
    echo "Please set your GitHub token:"
    echo "export GITHUB_TOKEN=\"your_token_here\""
    exit 1
fi

# Check if CODE_REPO is set
if [ -z "$CODE_REPO" ]; then
    echo "Warning: CODE_REPO not set, using default..."
    CODE_REPO="username/contact-graspnet"
    echo "Using code repository: $CODE_REPO"
    echo "To use a different repository, set:"
    echo "export CODE_REPO=\"username/repo-name\""
fi

# Navigate to project directory
PROJECT_DIR="$HOME/contact_graspnet"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory $PROJECT_DIR not found"
    echo "Please run the environment setup script first"
    exit 1
fi

cd "$PROJECT_DIR"

# Setup git with token authentication
echo "Setting up Git authentication..."

# Create a temporary git credential helper
TEMP_CRED_HELPER=$(mktemp)
cat > "$TEMP_CRED_HELPER" << EOF
#!/bin/bash
echo "username=\$GITHUB_TOKEN"
echo "password="
EOF
chmod +x "$TEMP_CRED_HELPER"

# Configure git to use the token
git config --global credential.helper "!$TEMP_CRED_HELPER"

# Alternative method: use HTTPS with token in URL
REPO_URL="https://${GITHUB_TOKEN}@github.com/${CODE_REPO}.git"

# Clone the repository
echo "Cloning repository: $CODE_REPO"
echo "This may take a while depending on repository size..."

if [ -d "src" ]; then
    echo "Source directory already exists, removing..."
    rm -rf src
fi

# Clone the repository
git clone "$REPO_URL" src

if [ $? -eq 0 ]; then
    echo "✅ Repository cloned successfully!"
else
    echo "❌ Failed to clone repository"
    echo "Please check:"
    echo "1. Your GitHub token has access to the repository"
    echo "2. The repository name is correct: $CODE_REPO"
    echo "3. Your internet connection is stable"
    
    # Clean up
    rm -f "$TEMP_CRED_HELPER"
    exit 1
fi

# Clean up git credentials for security
rm -f "$TEMP_CRED_HELPER"
git config --global --unset credential.helper

cd src

# Show repository information
echo ""
echo "📂 Repository Information:"
echo "Repository: $CODE_REPO"
echo "Location: $(pwd)"
echo "Branch: $(git branch --show-current)"
echo "Latest commit: $(git log -1 --oneline)"

# Show directory structure
echo ""
echo "📁 Directory structure:"
find . -maxdepth 3 -type d | head -20 | sort

# Look for setup/requirements files
echo ""
echo "🔍 Found configuration files:"
find . -maxdepth 2 -name "*.py" -o -name "*.txt" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.cfg" | grep -E "(setup|requirements|config|pyproject)" | head -10

# Check if there's a setup.py or requirements.txt in the source
if [ -f "setup.py" ]; then
    echo ""
    echo "📦 Found setup.py - installing package in development mode..."
    cd "$PROJECT_DIR"
    source .venv/bin/activate
    pip install -e ./src
elif [ -f "requirements.txt" ]; then
    echo ""
    echo "📦 Found requirements.txt - installing additional dependencies..."
    cd "$PROJECT_DIR"
    source .venv/bin/activate
    pip install -r ./src/requirements.txt
elif [ -f "pyproject.toml" ]; then
    echo ""
    echo "📦 Found pyproject.toml - installing package..."
    cd "$PROJECT_DIR"
    source .venv/bin/activate
    pip install -e ./src
fi

# Create convenience scripts
cd "$PROJECT_DIR"

# Create a run script
cat > run.sh << 'EOF'
#!/bin/bash
# Convenience script to run the main application
cd "$(dirname "$0")"
source .venv/bin/activate
export PYTHONPATH="$PWD/src:$PYTHONPATH"

if [ $# -eq 0 ]; then
    echo "Usage: ./run.sh <script_name> [args...]"
    echo "Available Python files in src:"
    find src -name "*.py" -type f | head -10
    exit 1
fi

python "$@"
EOF

chmod +x run.sh

# Create a development script
cat > develop.sh << 'EOF'
#!/bin/bash
# Setup development environment
cd "$(dirname "$0")"
source .venv/bin/activate
export PYTHONPATH="$PWD/src:$PYTHONPATH"

echo "🔧 Development environment activated!"
echo "Python: $(which python)"
echo "PYTHONPATH: $PYTHONPATH"
echo "Project directory: $PWD"
echo ""
echo "Available commands:"
echo "  python <script>     - Run a Python script"
echo "  jupyter notebook    - Start Jupyter notebook"
echo "  pip install <pkg>   - Install additional packages"
echo ""
exec bash
EOF

chmod +x develop.sh

echo ""
echo "✅ Code download completed successfully!"
echo "Code location: $PROJECT_DIR/src"
echo ""
echo "Convenience scripts created:"
echo "  ./run.sh <script>   - Run Python scripts"
echo "  ./develop.sh        - Enter development environment"
echo ""
echo "To start developing:"
echo "cd ~/contact_graspnet && ./develop.sh" 