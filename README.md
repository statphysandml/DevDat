# Welcome to DDevDat

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/statphysandml/DevDat/CI)](https://github.com/statphysandml/DevDat/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/statphysandml/DevDat/branch/main/graph/badge.svg)](https://codecov.io/gh/statphysandml/DevDat)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=statphysandml_DevDat&metric=alert_status)](https://sonarcloud.io/dashboard?id=statphysandml_DevDat)

# Prerequisites

Building DDevDat requires the following software installed:

* A C++17-compliant compiler
* CMake `>= 3.9`

# Building DDevDat

The following sequence of commands builds DDevDat.
It assumes that your current working directory is the top-level directory
of the freshly cloned repository:

```
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

The build process can be customized with the following CMake variables,
which can be set by adding `-D<var>={ON, OFF}` to the `cmake` call:

* `BUILD_TESTING`: Enable building of the test suite (default: `ON`)



# Testing DDevDat

When built according to the above explanation (with `-DBUILD_TESTING=ON`),
the C++ test suite of `DDevDat` can be run using
`ctest` from the build directory:

```
cd build
ctest
```


# Documentation

DDevDat *should* provide a documentation.