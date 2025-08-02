cmake_minimum_required(VERSION 3.18)

# Project definition
project(devdat VERSION 0.0.1 LANGUAGES CXX CUDA)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Optionally set CUDA architectures (uncomment and set as needed)
# set(CMAKE_CUDA_ARCHITECTURES 60 70 75 80 86)

# Install directories
include(GNUInstallDirs)

# Fetch nlohmann_json (modern FetchContent usage)
include(FetchContent)
FetchContent_Declare(
  json
  GIT_REPOSITORY https://github.com/ArthurSonzogni/nlohmann_json_cmake_fetchcontent
  GIT_TAG v3.0.0
  GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(json)

# Header-only library target
add_library(devdat INTERFACE)
target_include_directories(devdat INTERFACE
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Alias for downstream usage
add_library(devdat::devdat ALIAS devdat)

# Testing
include(CTest)
if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

# === Installation ===

install(
  TARGETS devdat
  EXPORT devdat-config
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
  EXPORT devdat-config
  NAMESPACE devdat::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/devdat
)

install(
  DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/include/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Feature summary
include(FeatureSummary)
feature_summary(WHAT ALL)
