#!/bin/bash
set -e

echo "=== Downloading Dataset from HuggingFace ==="

# Check if HF_TOKEN is set
if [ -z "$HF_TOKEN" ]; then
    echo "Error: HF_TOKEN environment variable is not set"
    echo "Please set your HuggingFace token:"
    echo "export HF_TOKEN=\"your_token_here\""
    exit 1
fi

# Check if DATASET_REPO is set
if [ -z "$DATASET_REPO" ]; then
    echo "Warning: DATASET_REPO not set, using default..."
    DATASET_REPO="contactgraspnet/dataset"
    echo "Using dataset repository: $DATASET_REPO"
    echo "To use a different repository, set:"
    echo "export DATASET_REPO=\"username/repo-name\""
fi

# Navigate to project directory
PROJECT_DIR="$HOME/contact_graspnet"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory $PROJECT_DIR not found"
    echo "Please run the environment setup script first"
    exit 1
fi

cd "$PROJECT_DIR"

# Initialize pyenv and activate virtual environment
if command -v pyenv &> /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

export PATH="$HOME/.cargo/bin:$PATH"
source .venv/bin/activate

# Install huggingface_hub if not already installed
echo "Ensuring huggingface_hub is available..."
python -c "import huggingface_hub" 2>/dev/null || pip install huggingface_hub

# Create data directory
mkdir -p data
cd data

# Login to HuggingFace
echo "Logging in to HuggingFace..."
echo "$HF_TOKEN" | python -c "
import sys
from huggingface_hub import login
token = sys.stdin.read().strip()
login(token=token)
print('Successfully logged in to HuggingFace')
"

# Download dataset
echo "Downloading dataset from $DATASET_REPO..."
echo "This may take a while depending on dataset size..."

python -c "
from huggingface_hub import snapshot_download
import os

repo_id = '$DATASET_REPO'
local_dir = './dataset'

print(f'Downloading {repo_id} to {local_dir}...')

try:
    snapshot_download(
        repo_id=repo_id,
        local_dir=local_dir,
        repo_type='dataset',
        resume_download=True
    )
    print('✅ Dataset downloaded successfully!')
    
    # List downloaded files
    print('\\nDownloaded files:')
    for root, dirs, files in os.walk(local_dir):
        level = root.replace(local_dir, '').count(os.sep)
        indent = ' ' * 2 * level
        print(f'{indent}{os.path.basename(root)}/')
        sub_indent = ' ' * 2 * (level + 1)
        for file in files[:5]:  # Show first 5 files per directory
            print(f'{sub_indent}{file}')
        if len(files) > 5:
            print(f'{sub_indent}... and {len(files) - 5} more files')
            
except Exception as e:
    print(f'Error downloading dataset: {e}')
    print('Please check:')
    print('1. Your HuggingFace token has access to the repository')
    print('2. The repository name is correct')
    print('3. Your internet connection is stable')
    exit(1)
"

# Create a simple verification script
cat > verify_dataset.py << 'EOF'
#!/usr/bin/env python3
"""Verify dataset integrity and structure"""

import os
from pathlib import Path

def verify_dataset():
    dataset_path = Path('./data/dataset')
    
    if not dataset_path.exists():
        print("❌ Dataset directory not found")
        return False
    
    print(f"✅ Dataset found at: {dataset_path.absolute()}")
    
    # Count files
    total_files = sum(1 for _ in dataset_path.rglob('*') if _.is_file())
    total_size = sum(f.stat().st_size for f in dataset_path.rglob('*') if f.is_file())
    
    print(f"📁 Total files: {total_files}")
    print(f"💾 Total size: {total_size / (1024**3):.2f} GB")
    
    # Show directory structure
    print("\n📂 Directory structure:")
    for root, dirs, files in os.walk(dataset_path):
        level = root.replace(str(dataset_path), '').count(os.sep)
        indent = '  ' * level
        print(f'{indent}{os.path.basename(root)}/')
        if level < 2:  # Only show first 2 levels
            sub_indent = '  ' * (level + 1)
            for d in dirs[:3]:
                print(f'{sub_indent}{d}/')
            if len(dirs) > 3:
                print(f'{sub_indent}... and {len(dirs) - 3} more directories')
    
    return True

if __name__ == "__main__":
    verify_dataset()
EOF

chmod +x verify_dataset.py

# Run verification
echo ""
echo "Verifying dataset..."
python verify_dataset.py

echo ""
echo "✅ Dataset download completed successfully!"
echo "Dataset location: $PROJECT_DIR/data/dataset"
echo "To verify dataset integrity later, run: python verify_dataset.py" 