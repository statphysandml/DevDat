cmake_minimum_required(VERSION 3.15)

# Set a name and a version number for your project:
project(Example VERSION 0.0.1 LANGUAGES CXX CUDA)

# Initialize some default paths
include(GNUInstallDirs)

# Define the minimum C++ standard that is required
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Include libraries
find_package(devdat CONFIG REQUIRED)

add_executable(devdat_examples src/devdat_t.cu src/random.cu main.cpp)
target_link_libraries(devdat_examples PRIVATE devdat::devdat)

target_include_directories(devdat_examples PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/>
)

# This prints a summary of found dependencies
include(FeatureSummary)
feature_summary(WHAT ALL)