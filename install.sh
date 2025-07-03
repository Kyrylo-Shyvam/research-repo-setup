#!/bin/bash
set -e

# Fix locale issues
export LC_ALL=C

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
print_status "This script will set up a complete Contact GraspNet environment using UV (No sudo required!)"

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
    echo "curl -sSL \"https://raw.githubusercontent.com/Kyrylo-Shyvam/research-repo-setup/main/install.sh?\$(date +%s)\" | bash"
    exit 1
fi

# Create setup directories in current directory
REPO_URL="https://raw.githubusercontent.com/Kyrylo-Shyvam/research-repo-setup/main"

print_status "Creating setup directories..."
mkdir -p scripts configs

print_status "Downloading setup scripts..."

# Download all required scripts and configs
curl -sSL "$REPO_URL/scripts/01_setup_python.sh" -o "scripts/01_setup_python.sh"
curl -sSL "$REPO_URL/scripts/02_setup_environment.sh" -o "scripts/02_setup_environment.sh"
curl -sSL "$REPO_URL/scripts/03_download_dataset.sh" -o "scripts/03_download_dataset.sh"
curl -sSL "$REPO_URL/scripts/04_download_code.sh" -o "scripts/04_download_code.sh"

# Download config files
curl -sSL "$REPO_URL/configs/requirements.txt" -o "configs/requirements.txt"
curl -sSL "$REPO_URL/configs/pyproject.toml" -o "configs/pyproject.toml"

# Make scripts executable
chmod +x scripts/*.sh

print_header "Step 1: Setting up Python 3.9 with pyenv"
bash scripts/01_setup_python.sh

print_header "Step 2: Setting up UV environment"
bash scripts/02_setup_environment.sh

print_header "Step 3: Downloading dataset from HuggingFace"
if [ "$DATASET_REPO" != "contactgraspnet/dataset" ]; then
    cd contact_graspnet
    bash ../scripts/03_download_dataset.sh
    cd ..
else
    print_warning "Skipping dataset download - using placeholder repository name"
    print_warning "Please update DATASET_REPO environment variable and run manually:"
    print_warning "export DATASET_REPO=\"actual/repo-name\" && cd contact_graspnet && bash ../scripts/03_download_dataset.sh"
fi

print_header "Step 4: Downloading code from GitHub"
if [ "$CODE_REPO" != "username/contact-graspnet" ]; then
    cd contact_graspnet
    bash ../scripts/04_download_code.sh
    cd ..
else
    print_warning "Skipping code download - using placeholder repository name"
    print_warning "Please update CODE_REPO environment variable and run manually:"
    print_warning "export CODE_REPO=\"actual/repo-name\" && cd contact_graspnet && bash ../scripts/04_download_code.sh"
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

# Clean up downloaded scripts (optional)
print_status "Cleaning up setup files..."
rm -rf scripts configs

print_success "Installation completed! Happy coding! 🚀" 