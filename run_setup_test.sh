#!/bin/bash
# Test script to run the setup and verify it works

cd /scratch/kiril/repo_setup

echo "Running stable environment setup..."
./setup_stable_env_v2.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "Setup completed successfully!"
    echo "Testing the environment..."
    source activate.sh
    ./test_env.py
else
    echo "Setup failed!"
    exit 1
fi