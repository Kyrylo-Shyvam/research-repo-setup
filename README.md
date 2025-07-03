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
1. Install pyenv (if not present)
2. Install Python 3.9
3. Install uv
4. Set up the environment with all dependencies in `./contact_graspnet/`
5. Download the dataset (requires HuggingFace token)
6. Clone the code repository (requires GitHub token)

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

## Directory Structure

```
repo_setup/
├── install.sh              # One-liner installation script
├── scripts/
│   ├── 01_setup_python.sh    # Install pyenv and Python 3.9
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