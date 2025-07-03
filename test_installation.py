#!/usr/bin/env python3
"""
Quick test script to verify Contact GraspNet installation
"""

import sys
import traceback

def test_imports():
    """Test importing all required packages"""
    print("🧪 Testing package imports...")
    
    tests = [
        ("PyTorch", "torch"),
        ("NumPy", "numpy"),
        ("OpenCV", "cv2"),
        ("Open3D", "open3d"),
        ("Trimesh", "trimesh"),
        ("Matplotlib", "matplotlib.pyplot"),
        ("Scikit-learn", "sklearn"),
        ("H5PY", "h5py"),
        ("PyRender", "pyrender"),
        ("TensorBoard", "tensorboard"),
        ("Pandas", "pandas"),
        ("SciPy", "scipy"),
    ]
    
    passed = 0
    failed = 0
    
    for name, module in tests:
        try:
            __import__(module)
            print(f"  ✅ {name}")
            passed += 1
        except ImportError as e:
            print(f"  ❌ {name}: {e}")
            failed += 1
        except Exception as e:
            print(f"  ⚠️  {name}: {e}")
            failed += 1
    
    print(f"\nImport Results: {passed} passed, {failed} failed")
    return failed == 0

def test_pytorch_cuda():
    """Test PyTorch CUDA functionality"""
    print("\n🔥 Testing PyTorch CUDA...")
    
    try:
        import torch
        print(f"  PyTorch version: {torch.__version__}")
        print(f"  CUDA available: {torch.cuda.is_available()}")
        
        if torch.cuda.is_available():
            print(f"  CUDA version: {torch.version.cuda}")
            print(f"  GPU count: {torch.cuda.device_count()}")
            
            # Test tensor operations on GPU
            x = torch.randn(3, 3).cuda()
            y = torch.randn(3, 3).cuda()
            z = torch.mm(x, y)
            print(f"  ✅ GPU tensor operations working")
            return True
        else:
            print(f"  ⚠️  CUDA not available - CPU only")
            return False
            
    except Exception as e:
        print(f"  ❌ PyTorch CUDA test failed: {e}")
        return False

def test_computer_vision():
    """Test computer vision functionality"""
    print("\n📷 Testing computer vision packages...")
    
    try:
        import numpy as np
        import cv2
        import open3d as o3d
        
        # Test OpenCV
        img = np.zeros((100, 100, 3), dtype=np.uint8)
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        print("  ✅ OpenCV operations working")
        
        # Test Open3D
        mesh = o3d.geometry.TriangleMesh.create_sphere()
        print("  ✅ Open3D operations working")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Computer vision test failed: {e}")
        traceback.print_exc()
        return False

def main():
    """Run all tests"""
    print("🚀 Contact GraspNet Installation Test")
    print("=" * 50)
    
    all_passed = True
    
    # Test imports
    all_passed &= test_imports()
    
    # Test PyTorch CUDA
    all_passed &= test_pytorch_cuda()
    
    # Test computer vision
    all_passed &= test_computer_vision()
    
    print("\n" + "=" * 50)
    if all_passed:
        print("🎉 All tests passed! Installation looks good.")
        return 0
    else:
        print("❌ Some tests failed. Check the output above.")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 