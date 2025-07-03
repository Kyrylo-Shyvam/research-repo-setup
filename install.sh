#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
    echo -e "${NC}"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is designed for Linux systems only"
    exit 1
fi

print_header "Contact GraspNet One-Liner Setup"
print_status "This script will set up a complete Contact GraspNet environment using UV"

# Check for required environment variables
MISSING_VARS=()

if [ -z "$HF_TOKEN" ]; then
    MISSING_VARS+=("HF_TOKEN")
fi

if [ -z "$GITHUB_TOKEN" ]; then
    MISSING_VARS+=("GITHUB_TOKEN")
fi

if [ -z "$DATASET_REPO" ]; then
    print_warning "DATASET_REPO not set, will use default placeholder"
    export DATASET_REPO="contactgraspnet/dataset"
fi

if [ -z "$CODE_REPO" ]; then
    print_warning "CODE_REPO not set, will use default placeholder"
    export CODE_REPO="username/contact-graspnet"
fi

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    print_error "Missing required environment variables: ${MISSING_VARS[*]}"
    echo ""
    echo "Please set the following variables before running this script:"
    echo ""
    if [[ " ${MISSING_VARS[@]} " =~ " HF_TOKEN " ]]; then
        echo "export HF_TOKEN=\"your_huggingface_token\""
    fi
    if [[ " ${MISSING_VARS[@]} " =~ " GITHUB_TOKEN " ]]; then
        echo "export GITHUB_TOKEN=\"your_github_token\""
    fi
    echo ""
    echo "Optional (will use defaults if not set):"
    echo "export DATASET_REPO=\"username/dataset-repo\""
    echo "export CODE_REPO=\"username/code-repo\""
    echo ""
    echo "Then run this script again:"
    echo "curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh | bash"
    exit 1
fi

# Create temporary directory for setup files
TEMP_DIR=$(mktemp -d)
REPO_URL="https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main"

print_status "Downloading setup scripts..."

# Download all required scripts and configs
curl -sSL "$REPO_URL/scripts/01_setup_python.sh" -o "$TEMP_DIR/01_setup_python.sh"
curl -sSL "$REPO_URL/scripts/02_setup_environment.sh" -o "$TEMP_DIR/02_setup_environment.sh"
curl -sSL "$REPO_URL/scripts/03_download_dataset.sh" -o "$TEMP_DIR/03_download_dataset.sh"
curl -sSL "$REPO_URL/scripts/04_download_code.sh" -o "$TEMP_DIR/04_download_code.sh"

# Download config files
mkdir -p "$TEMP_DIR/configs"
curl -sSL "$REPO_URL/configs/requirements.txt" -o "$TEMP_DIR/configs/requirements.txt"
curl -sSL "$REPO_URL/configs/pyproject.toml" -o "$TEMP_DIR/configs/pyproject.toml"

# Make scripts executable
chmod +x "$TEMP_DIR"/*.sh

print_header "Step 1: Setting up Python 3.9 with pyenv"
bash "$TEMP_DIR/01_setup_python.sh"

print_header "Step 2: Setting up UV environment"
# Change to temp directory so scripts can find configs
cd "$TEMP_DIR"
bash "$TEMP_DIR/02_setup_environment.sh"

# Change back to original directory and move the project
cd -
if [ -d "$TEMP_DIR/contact_graspnet" ]; then
    mv "$TEMP_DIR/contact_graspnet" ./
    print_status "Project created in: $(pwd)/contact_graspnet"
fi

print_header "Step 3: Downloading dataset from HuggingFace"
if [ "$DATASET_REPO" != "contactgraspnet/dataset" ]; then
    cd contact_graspnet
    bash "$TEMP_DIR/03_download_dataset.sh"
    cd ..
else
    print_warning "Skipping dataset download - using placeholder repository name"
    print_warning "Please update DATASET_REPO environment variable and run manually:"
    print_warning "export DATASET_REPO=\"actual/repo-name\" && cd contact_graspnet && bash $TEMP_DIR/03_download_dataset.sh"
fi

print_header "Step 4: Downloading code from GitHub"
if [ "$CODE_REPO" != "username/contact-graspnet" ]; then
    cd contact_graspnet
    bash "$TEMP_DIR/04_download_code.sh"
    cd ..
else
    print_warning "Skipping code download - using placeholder repository name"
    print_warning "Please update CODE_REPO environment variable and run manually:"
    print_warning "export CODE_REPO=\"actual/repo-name\" && cd contact_graspnet && bash $TEMP_DIR/04_download_code.sh"
fi

print_header "Setup Complete!"

print_success "Contact GraspNet environment has been set up successfully!"
echo ""
print_status "Summary of what was installed:"
echo "  ✅ Python 3.9 (via pyenv)"
echo "  ✅ UV package manager"
echo "  ✅ Contact GraspNet environment with all dependencies"
echo "  ✅ PyTorch with CUDA support"
if [ "$DATASET_REPO" != "contactgraspnet/dataset" ]; then
    echo "  ✅ Dataset from HuggingFace"
else
    echo "  ⏸️  Dataset download (requires manual setup)"
fi
if [ "$CODE_REPO" != "username/contact-graspnet" ]; then
    echo "  ✅ Source code from GitHub"
else
    echo "  ⏸️  Code download (requires manual setup)"
fi

echo ""
print_status "Project location: $(pwd)/contact_graspnet"
echo ""
print_status "To get started:"
echo "  cd contact_graspnet"
echo "  source .venv/bin/activate    # Activate environment"
echo "  ./develop.sh                 # Enter development mode"
echo ""
print_status "Available convenience scripts:"
echo "  ./activate.sh    - Activate environment"
echo "  ./run.sh <file>  - Run Python scripts"
echo "  ./develop.sh     - Development environment"

# Clean up
rm -rf "$TEMP_DIR"

print_success "Installation completed! Happy coding! 🚀" 