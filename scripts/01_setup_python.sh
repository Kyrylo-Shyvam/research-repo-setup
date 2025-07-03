#!/bin/bash
set -e

echo "=== Setting up Python 3.9 with pyenv ==="

# Check if Python 3.9 is already available
if command -v python3.9 &> /dev/null; then
    echo "Python 3.9 is already available"
    python3.9 --version
    exit 0
fi

# Install pyenv if not present
if ! command -v pyenv &> /dev/null; then
    echo "Installing pyenv..."
    
    # Install dependencies
    sudo apt-get update
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev git
    
    # Install pyenv
    curl https://pyenv.run | bash
    
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
    
    echo "Pyenv installed successfully"
else
    echo "Pyenv is already installed"
    # Initialize pyenv in current session
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Install Python 3.9 if not available
if ! pyenv versions | grep -q "3.9"; then
    echo "Installing Python 3.9..."
    pyenv install 3.9.16
    echo "Python 3.9.16 installed successfully"
else
    echo "Python 3.9 is already installed via pyenv"
fi

# Set Python 3.9 as global version
pyenv global 3.9.16

# Verify installation
echo "Verifying Python installation..."
python --version
python -m pip --version

echo "✅ Python 3.9 setup completed successfully!" 