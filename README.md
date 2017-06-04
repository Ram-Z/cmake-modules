# cmake-modules

Some common CMake modules and functions.

## Installation

Add it as a git submodule to your project:
```bash
git submodule add https://github.com/Ram-Z/cmake-modules cmake
```

And add the following in your top-level `CMakeLists.txt`:
```cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
```
