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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=== Setting up Python 3.9 (No Sudo Required) ==="

# Function to check if a Python version is 3.9.x
check_python39() {
    local python_cmd="$1"
    if command -v "$python_cmd" &> /dev/null; then
        local version=$($python_cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [[ "$version" == "3.9" ]]; then
            return 0
        fi
    fi
    return 1
}

# Strategy 1: Check for existing Python 3.9
print_status "Checking for existing Python 3.9..."
if check_python39 "python3.9"; then
    print_success "Found python3.9"
    ln -sf $(which python3.9) ~/.local/bin/python 2>/dev/null || true
    python3.9 --version
    exit 0
elif check_python39 "python3"; then
    print_success "Found python3 with version 3.9"
    ln -sf $(which python3) ~/.local/bin/python 2>/dev/null || true
    python3 --version
    exit 0
elif check_python39 "python"; then
    print_success "Found python with version 3.9"
    ln -sf $(which python) ~/.local/bin/python 2>/dev/null || true
    python --version
    exit 0
fi

print_warning "Python 3.9 not found in system. Installing Python 3.9..."

# Create local bin directory
mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Strategy 2: Try pyenv (primary method)
print_status "Installing Python 3.9 via pyenv..."

if ! command -v pyenv &> /dev/null; then
    print_status "Installing pyenv..."
    
    # Install pyenv
    if curl https://pyenv.run | bash; then
    # Add pyenv to PATH and bashrc
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    # Add to bashrc if not already there
    if ! grep -q 'pyenv init' ~/.bashrc; then
        echo '' >> ~/.bashrc
        echo '# Pyenv configuration' >> ~/.bashrc
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    fi
    
        print_success "Pyenv installed successfully"
    else
        print_error "Failed to install pyenv"
        print_warning "Trying Miniconda as fallback..."
        
        # Fallback to Miniconda
        print_status "Attempting to install Python 3.9 via Miniconda..."
        if ! command -v conda &> /dev/null; then
            print_status "Installing Miniconda..."
            
            # Download miniconda installer
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
            INSTALLER_PATH="/tmp/miniconda_installer.sh"
            
            if curl -sSL "$MINICONDA_URL" -o "$INSTALLER_PATH"; then
                print_status "Downloaded Miniconda installer"
                
                # Install miniconda in user space
                bash "$INSTALLER_PATH" -b -p "$HOME/.miniconda3"
                
                # Initialize conda
                source "$HOME/.miniconda3/etc/profile.d/conda.sh"
                conda config --set auto_activate_base false
                
                # Add to bashrc if not already there
                if ! grep -q 'miniconda3/etc/profile.d/conda.sh' ~/.bashrc; then
                    echo '' >> ~/.bashrc
                    echo '# Miniconda configuration' >> ~/.bashrc
                    echo 'source "$HOME/.miniconda3/etc/profile.d/conda.sh"' >> ~/.bashrc
                fi
                
                print_success "Miniconda installed successfully"
                
                # Create Python 3.9 environment
                print_status "Creating Python 3.9 environment..."
                conda create -n python39 python=3.9 -y
                conda activate python39
                
                # Create symlink for easier access
                ln -sf "$HOME/.miniconda3/envs/python39/bin/python" ~/.local/bin/python
                ln -sf "$HOME/.miniconda3/envs/python39/bin/python" ~/.local/bin/python3.9
                
                # Verify installation
                print_success "Python 3.9 installed via Miniconda"
                ~/.local/bin/python --version
                
                # Clean up installer
                rm -f "$INSTALLER_PATH"
                exit 0
            else
                print_error "Failed to download Miniconda installer"
                exit 1
            fi
        fi
    fi
else
    print_status "Pyenv is already installed"
    # Initialize pyenv in current session
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Try to install Python 3.9 with pyenv
if ! pyenv versions | grep -q "3.9"; then
    print_status "Installing Python 3.9 with pyenv..."
    print_warning "If this fails, you may need to install build dependencies manually:"
    print_warning "  On Ubuntu/Debian: sudo apt-get install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git"
    print_warning "  On CentOS/RHEL: sudo yum groupinstall 'Development Tools' && sudo yum install openssl-devel bzip2-devel libffi-devel"
    
    if pyenv install 3.9.16; then
        print_success "Python 3.9.16 installed successfully with pyenv"
    else
        print_error "Failed to install Python 3.9 with pyenv"
        print_warning "Trying Miniconda as fallback..."
        
        # Fallback to Miniconda
        print_status "Attempting to install Python 3.9 via Miniconda..."
        if ! command -v conda &> /dev/null; then
            print_status "Installing Miniconda..."
            
            # Download miniconda installer
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
            INSTALLER_PATH="/tmp/miniconda_installer.sh"
            
            if curl -sSL "$MINICONDA_URL" -o "$INSTALLER_PATH"; then
                print_status "Downloaded Miniconda installer"
                
                # Install miniconda in user space
                bash "$INSTALLER_PATH" -b -p "$HOME/.miniconda3"
                
                # Initialize conda
                source "$HOME/.miniconda3/etc/profile.d/conda.sh"
                conda config --set auto_activate_base false
                
                # Add to bashrc if not already there
                if ! grep -q 'miniconda3/etc/profile.d/conda.sh' ~/.bashrc; then
                    echo '' >> ~/.bashrc
                    echo '# Miniconda configuration' >> ~/.bashrc
                    echo 'source "$HOME/.miniconda3/etc/profile.d/conda.sh"' >> ~/.bashrc
                fi
                
                print_success "Miniconda installed successfully"
                
                # Create Python 3.9 environment
                print_status "Creating Python 3.9 environment..."
                conda create -n python39 python=3.9 -y
                conda activate python39
                
                # Create symlink for easier access
                ln -sf "$HOME/.miniconda3/envs/python39/bin/python" ~/.local/bin/python
                ln -sf "$HOME/.miniconda3/envs/python39/bin/python" ~/.local/bin/python3.9
                
                # Verify installation
                print_success "Python 3.9 installed via Miniconda"
                ~/.local/bin/python --version
                
                # Clean up installer
                rm -f "$INSTALLER_PATH"
                exit 0
            else
                print_error "Failed to download Miniconda installer"
                print_error "All Python installation methods failed"
                exit 1
            fi
        else
            print_status "Conda already available, creating Python 3.9 environment..."
            source "$HOME/.miniconda3/etc/profile.d/conda.sh" 2>/dev/null || true
            
            if conda env list | grep -q python39; then
                print_status "Python 3.9 environment already exists"
            else
                conda create -n python39 python=3.9 -y
            fi
            
            conda activate python39
            ln -sf "$HOME/.miniconda3/envs/python39/bin/python" ~/.local/bin/python
            ln -sf "$HOME/.miniconda3/envs/python39/bin/python" ~/.local/bin/python3.9
            print_success "Python 3.9 environment ready"
            ~/.local/bin/python --version
            exit 0
        fi
    fi
else
    print_status "Python 3.9 is already installed via pyenv"
fi

# Set Python 3.9 as global version
pyenv global 3.9.16

# Create symlinks for easier access
mkdir -p ~/.local/bin
ln -sf "$(pyenv which python)" ~/.local/bin/python
ln -sf "$(pyenv which python)" ~/.local/bin/python3.9

# Verify installation
echo "Verifying Python installation..."
python --version
python -m pip --version

print_success "✅ Python 3.9 setup completed successfully!" 