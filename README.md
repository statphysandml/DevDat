# Welcome to DevDat

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/statphysandml/DevDat/CI)](https://github.com/statphysandml/DevDat/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/statphysandml/DevDat/branch/main/graph/badge.svg)](https://codecov.io/gh/statphysandml/DevDat)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=statphysandml_DevDat&metric=alert_status)](https://sonarcloud.io/dashboard?id=statphysandml_DevDat)

# Prerequisites

Building DevDat requires the following software installed:

* A C++17-compliant compiler
* CMake `>= 3.15`
* Cuda `>=10.1`

# Building and Installing DevDat

The recommended way to build and install DevDat is with an out-of-source build:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/local
cmake --build build --target install
```

This will install DevDat to `$HOME/local` by default.  
If you want to install to a different location, adjust the `CMAKE_INSTALL_PREFIX` accordingly.

> **Note:** If you install to a custom location, set `CMAKE_PREFIX_PATH` when using DevDat in other projects:
>
> ```sh
> cmake -S . -B build -DCMAKE_PREFIX_PATH=$HOME/local
> ```

# Building and Running the Example

To build the example, first ensure DevDat is installed as above. Then:

```sh
cmake -S examples -B examples/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/local
cmake --build examples/build
```

To run the example:

```sh
./examples/build/devdat_examples
```

# Running Tests

If you enabled tests (`-DBUILD_TESTING=ON`):

```sh
cmake -S . -B build -DBUILD_TESTING=ON
cmake --build build
cd build
ctest
```
# Documentation

ToDo
