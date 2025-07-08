# Contact GraspNet Stable Environment Setup

This repository provides a stable, reproducible setup for the Contact GraspNet environment using `uv` with CUDA support for PyTorch.

## Quick Start

1. **Clone this repository**:
```bash
git clone <repository-url> contact_graspnet
cd contact_graspnet
```

2. **Run the stable setup script**:
```bash
./setup_stable_env_v2.sh
```

3. **Activate the environment**:
```bash
source activate.sh
```

4. **Test the installation**:
```bash
./test_env.py
```

## What the Setup Does

1. **Installs UV**: A fast Python package installer and resolver
2. **Creates Virtual Environment**: Isolated Python 3.9 environment
3. **Installs Dependencies**: 
   - PyTorch 2.0.1 with CUDA 11.7 support
   - Core scientific packages (NumPy, SciPy, Pandas)
   - Computer vision libraries (OpenCV, Open3D)
   - Visualization tools (Matplotlib, Plotly)
   - Development tools (pytest, black, flake8, mypy)

## Repository Structure

```
contact_graspnet/
├── .venv/                   # Virtual environment (created by setup)
├── configs/                 # Configuration files
│   ├── pyproject.toml      # Project metadata
│   ├── requirements.txt     # Original requirements
│   └── requirements_stable.txt  # Curated stable requirements
├── scripts/                 # Setup and utility scripts
├── src/                     # Source code (add your code here)
├── activate.sh             # Environment activation script
├── run.sh                  # Python runner with environment
├── develop.sh              # Development environment launcher
├── test_env.py             # Environment test script
└── setup_stable_env_v2.sh  # Main setup script

```

## Usage

### Running Python Scripts
```bash
# Option 1: Using run.sh
./run.sh your_script.py

# Option 2: Activate environment first
source activate.sh
python your_script.py
```

### Development Mode
```bash
./develop.sh
# This activates the environment and provides a shell with all tools available
```

## Troubleshooting

### CUDA Issues
If CUDA is not detected:
1. Check NVIDIA drivers: `nvidia-smi`
2. Verify CUDA installation: `nvcc --version`
3. Ensure GPU is available: `lspci | grep -i nvidia`

### Package Installation Failures
If packages fail to install:
1. Check the installation log for specific errors
2. Try installing problematic packages individually:
   ```bash
   source activate.sh
   uv pip install <package-name>
   ```

### Python Version Issues
The setup requires Python 3.9. If not available:
1. The setup script will attempt to install it via pyenv
2. If that fails, it will use Miniconda as a fallback
3. You can also install Python 3.9 manually

### Memory Issues
For large installations on systems with limited memory:
1. Close other applications
2. Use `--no-cache-dir` flag with pip
3. Install packages in smaller batches

## Environment Variables

Set these before running scripts that need external access:
```bash
export HF_TOKEN="your_huggingface_token"
export GITHUB_TOKEN="your_github_token"
```

## Updating Dependencies

To update packages while maintaining stability:
1. Update the `requirements_stable.txt` file
2. Re-run the setup script
3. Test thoroughly before committing changes

## Contributing

When adding new dependencies:
1. Test compatibility with existing packages
2. Pin versions for reproducibility
3. Update `requirements_stable.txt`
4. Document any special installation requirements

## Performance Tips

1. **Use GPU acceleration**: Ensure CUDA is properly configured
2. **Optimize batch sizes**: Adjust based on available GPU memory
3. **Enable mixed precision**: Use PyTorch's automatic mixed precision for faster training
4. **Profile your code**: Use PyTorch's profiler to identify bottlenecks

## Security Notes

- Never commit tokens or credentials
- Use environment variables for sensitive data
- Keep dependencies updated for security patches
- Review code from external sources before running

## Support

If you encounter issues:
1. Check the troubleshooting section
2. Review the installation logs
3. Ensure all prerequisites are met
4. Create an issue with detailed error information