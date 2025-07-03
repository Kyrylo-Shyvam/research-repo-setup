# Contact GraspNet Environment Setup

This repository provides a complete setup for the Contact GraspNet environment using `uv` instead of conda, with CUDA support for PyTorch.

## One-Liner Installation

**Standard installation:**
```bash
curl -sSL https://raw.githubusercontent.com/Kyrylo-Shyvam/research-repo-setup/main/install.sh | bash
```

**Bypass caching (recommended for development):**
```bash
curl -sSL "https://raw.githubusercontent.com/Kyrylo-Shyvam/research-repo-setup/main/install.sh?$(date +%s)" | bash
```

This will:
1. Install Python 3.9 (via system Python, Miniconda, or pyenv - **no sudo required**)
2. Install uv
3. Set up the environment with all dependencies in `./contact_graspnet/`
4. Download the dataset (requires HuggingFace token)
5. Clone the code repository (requires GitHub token)

## Manual Installation

If you prefer to run each step manually:

```bash
# 1. Environment setup
./scripts/01_setup_python.sh
./scripts/02_setup_environment.sh

# 2. Dataset download (run from contact_graspnet directory)
cd contact_graspnet
../scripts/03_download_dataset.sh

# 3. Code download (run from contact_graspnet directory)
../scripts/04_download_code.sh
```

## Requirements

- Linux system with GPU
- HuggingFace token (for dataset access)
- GitHub token (for private repository access)
- **No sudo/root access required!**

## Python Installation Strategy

The setup uses a multi-strategy approach to install Python 3.9 without requiring sudo:

1. **System Python**: Checks if Python 3.9 is already available on the system
2. **Pyenv**: Installs pyenv and Python 3.9 (primary method)
3. **Miniconda fallback**: Installs Miniconda in user space if pyenv fails

This ensures the setup works in environments where you don't have administrative privileges.

## Environment Variables

Set these before running the scripts:

```bash
export HF_TOKEN="your_huggingface_token"
export GITHUB_TOKEN="your_github_token"
export DATASET_REPO="username/dataset-repo"  # HuggingFace dataset repo
export CODE_REPO="username/code-repo"        # GitHub code repo
```

## Troubleshooting

### Caching Issues
If you get old versions of the script, use the cache-busting version:
```bash
curl -sSL "https://raw.githubusercontent.com/Kyrylo-Shyvam/research-repo-setup/main/install.sh?$(date +%s)" | bash
```

### 404 Errors
If you see "404:: command not found", the script download failed. Try:
1. Check if the repository is public or if you have access
2. Verify the URL is correct
3. Download manually first to check:
```bash
curl -sSL https://raw.githubusercontent.com/Kyrylo-Shyvam/research-repo-setup/main/install.sh -o test_install.sh
head -10 test_install.sh  # Should show bash script, not HTML
```

### Locale Warnings
To fix locale warnings, run:
```bash
export LC_ALL=C
# or
export LC_ALL=en_US.UTF-8
```

### Python Installation Issues
If Python 3.9 installation fails:

1. **Miniconda installation failed**: Check internet connection and disk space
2. **Pyenv build failed**: Install build dependencies manually:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git
   
   # CentOS/RHEL
   sudo yum groupinstall 'Development Tools' && sudo yum install openssl-devel bzip2-devel libffi-devel
   ```
3. **Limited environment**: The script will try system Python first, so ensure Python 3.9 is available if you can't install additional software

## Directory Structure

```
repo_setup/
├── install.sh              # One-liner installation script
├── scripts/
│   ├── 01_setup_python.sh    # Install Python 3.9 (sudo-free: system/miniconda/pyenv)
│   ├── 02_setup_environment.sh # Setup uv environment
│   ├── 03_download_dataset.sh  # Download dataset from HuggingFace
│   ├── 04_download_code.sh     # Download code from GitHub
│   └── parse_conda_env.py      # Utility to convert conda env to requirements.txt
├── configs/
│   ├── requirements.txt      # Python dependencies (generated from conda env)
│   └── pyproject.toml        # UV project configuration
├── verify_setup.sh          # Verification script
├── test_installation.py     # Installation test script
└── README.md               # This file
```

After installation, the project structure will be:

```
./contact_graspnet/          # Created in current directory
├── .venv/                   # UV virtual environment
├── src/                     # Downloaded source code
├── data/
│   └── dataset/             # Downloaded dataset
├── pyproject.toml           # Project configuration
├── requirements.txt         # Dependencies
├── activate.sh              # Environment activation script
├── run.sh                   # Script runner
└── develop.sh               # Development environment
```

## Post-Installation

After installation, activate the environment:

```bash
cd contact_graspnet
source .venv/bin/activate
# or
./activate.sh
```

## Verification

To verify your installation:

```bash
./verify_setup.sh      # Check all components
./test_installation.py # Test Python packages
```

## Development

Enter development mode:

```bash
cd contact_graspnet
./develop.sh
```

This will activate the environment and set up PYTHONPATH for development. 