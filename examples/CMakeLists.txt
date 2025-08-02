cmake_minimum_required(VERSION 3.18)

project(Example VERSION 0.0.1 LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Optionally set CUDA architectures (uncomment and set as needed)
# set(CMAKE_CUDA_ARCHITECTURES 60 70 75 80 86)

include(GNUInstallDirs)

find_package(devdat CONFIG REQUIRED)

add_executable(devdat_examples
    src/devdat_t.cu
    src/random.cu
    main.cpp
)

target_link_libraries(devdat_examples PRIVATE devdat::devdat)

target_include_directories(devdat_examples PRIVATE
    ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
)

include(FeatureSummary)
feature_summary(WHAT ALL)