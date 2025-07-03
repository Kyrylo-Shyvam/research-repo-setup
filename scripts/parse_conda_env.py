#!/usr/bin/env python3
"""
Parse conda environment.yml file and generate requirements.txt for uv
"""

import yaml
import re
import sys
from pathlib import Path

def parse_conda_env_to_requirements(yml_file, output_file):
    """Parse conda environment yml and create requirements.txt"""
    
    with open(yml_file, 'r') as f:
        env_data = yaml.safe_load(f)
    
    requirements = []
    pip_packages = []
    
    # Add extra index for PyTorch CUDA
    requirements.append("--extra-index-url https://download.pytorch.org/whl/cu117")
    requirements.append("")
    
    # Process conda dependencies
    conda_deps = env_data.get('dependencies', [])
    
    for dep in conda_deps:
        if isinstance(dep, str):
            # Skip system packages and conda-specific packages
            if any(skip in dep for skip in ['_libgcc_mutex', '_openmp_mutex', 'cuda-', 'libcu', 'lib']):
                continue
            
            # Convert conda package names to pip equivalents
            package_name = dep.split('=')[0]
            
            # Skip packages that are typically system-level or conda-specific
            skip_packages = {
                'binutils_impl_linux-64', 'binutils_linux-64', 'gcc_impl_linux-64', 
                'gcc_linux-64', 'gxx_impl_linux-64', 'gxx_linux-64', 'kernel-headers_linux-64',
                'ld_impl_linux-64', 'libgcc-devel_linux-64', 'libstdcxx-devel_linux-64',
                'sysroot_linux-64', 'python_abi', 'pytorch-mutex', 'blas', 'mkl', 'mkl-service',
                'mkl_fft', 'mkl_random', 'intel-openmp', 'tbb'
            }
            
            if package_name in skip_packages:
                continue
                
            # Handle special package name mappings
            name_mappings = {
                'pytorch': 'torch==2.0.1+cu117',
                'torchvision': 'torchvision==0.15.2+cu117', 
                'torchaudio': 'torchaudio==2.0.2+cu117',
                'opencv-python': 'opencv-python',
                'python-dateutil': 'python-dateutil',
                'python-fastjsonschema': 'jsonschema',
                'python-kaleido': 'kaleido',
                'python-fcl': 'python-fcl'
            }
            
            if package_name in name_mappings:
                requirements.append(name_mappings[package_name])
            elif package_name == 'python':
                continue  # Skip python itself
            elif '=' in dep:
                # Extract version
                parts = dep.split('=')
                name = parts[0]
                version = parts[1]
                if name not in ['ca-certificates', 'certifi', 'openssl']:  # Skip system certs
                    # Convert some common conda->pip package names
                    if name == 'freetype-py':
                        name = 'freetype-py'
                    elif name == 'python-kaleido':
                        name = 'kaleido'
                    
                    requirements.append(f"{name}=={version}")
                    
        elif isinstance(dep, dict) and 'pip' in dep:
            # Handle pip dependencies
            pip_packages.extend(dep['pip'])
    
    # Add pip packages
    for pkg in pip_packages:
        if '==' in pkg:
            requirements.append(pkg)
        else:
            requirements.append(pkg)
    
    # Write requirements.txt
    with open(output_file, 'w') as f:
        f.write("# Generated from conda environment yml\n")
        f.write("# PyTorch with CUDA support\n")
        f.write("--extra-index-url https://download.pytorch.org/whl/cu117\n\n")
        
        # Core PyTorch packages first
        pytorch_packages = []
        other_packages = []
        
        for req in requirements:
            if req.startswith('--extra-index-url') or req == '':
                continue
            elif any(torch_pkg in req for torch_pkg in ['torch==', 'torchvision==', 'torchaudio==']):
                pytorch_packages.append(req)
            else:
                other_packages.append(req)
        
        # Write PyTorch packages
        if pytorch_packages:
            f.write("# PyTorch with CUDA\n")
            for pkg in pytorch_packages:
                f.write(f"{pkg}\n")
            f.write("\n")
        
        # Write other packages
        f.write("# Other dependencies\n")
        for pkg in sorted(set(other_packages)):
            if pkg and not pkg.startswith('#'):
                f.write(f"{pkg}\n")

def main():
    script_dir = Path(__file__).parent
    yml_file = script_dir.parent / "contact_graspnet_env.yml"
    output_file = script_dir.parent / "configs" / "requirements.txt"
    
    if not yml_file.exists():
        print(f"Error: {yml_file} not found")
        sys.exit(1)
    
    # Create configs directory if it doesn't exist
    output_file.parent.mkdir(exist_ok=True)
    
    parse_conda_env_to_requirements(yml_file, output_file)
    print(f"Generated requirements.txt from {yml_file}")
    print(f"Output written to {output_file}")

if __name__ == "__main__":
    main() 