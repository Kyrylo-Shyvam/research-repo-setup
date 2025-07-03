# Contact GraspNet Environment Setup

This repository provides a complete setup for the Contact GraspNet environment using `uv` instead of conda, with CUDA support for PyTorch.

## One-Liner Installation

```bash
curl -sSL https://raw.githubusercontent.com/Kyrylo-Shyvam/research-repo-setup/main/install.sh | bash
```

This will:
1. Install pyenv (if not present)
2. Install Python 3.9
3. Install uv
4. Set up the environment with all dependencies
5. Download the dataset (requires HuggingFace token)
6. Clone the code repository (requires GitHub token)

## Manual Installation

If you prefer to run each step manually:

```bash
# 1. Environment setup
./scripts/01_setup_python.sh
./scripts/02_setup_environment.sh

# 2. Dataset download
./scripts/03_download_dataset.sh

# 3. Code download
./scripts/04_download_code.sh
```

## Requirements

- Linux system with GPU
- HuggingFace token (for dataset access)
- GitHub token (for private repository access)

## Environment Variables

Set these before running the scripts:

```bash
export HF_TOKEN="your_huggingface_token"
export GITHUB_TOKEN="your_github_token"
export DATASET_REPO="username/dataset-repo"  # HuggingFace dataset repo
export CODE_REPO="username/code-repo"        # GitHub code repo
```

## Directory Structure

```
repo_setup/
├── install.sh              # One-liner installation script
├── scripts/
│   ├── 01_setup_python.sh    # Install pyenv and Python 3.9
│   ├── 02_setup_environment.sh # Setup uv environment
│   ├── 03_download_dataset.sh  # Download dataset from HuggingFace
│   └── 04_download_code.sh     # Download code from GitHub
├── configs/
│   ├── requirements.txt      # Python dependencies
│   └── pyproject.toml        # UV project configuration
└── README.md               # This file
```

## Post-Installation

After installation, activate the environment:

```bash
source ~/.bashrc  # Reload shell
cd contact_graspnet
source .venv/bin/activate
``` 