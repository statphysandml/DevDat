cmake_minimum_required(VERSION 3.15)

# Silence warnings about empty CUDA_ARCHITECTURES properties on example targets:
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.18)
  cmake_policy(SET CMP0104 OLD)
endif()

# Set a name and a version number for your project:
project(devdat VERSION 0.0.1 LANGUAGES CXX CUDA)

# Initialize some default paths
include(GNUInstallDirs)

# Define the minimum C++ standard that is required
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Add nlohmann json
include(FetchContent)

FetchContent_Declare(json
  GIT_REPOSITORY https://github.com/ArthurSonzogni/nlohmann_json_cmake_fetchcontent
  GIT_PROGRESS TRUE
  GIT_SHALLOW TRUE
  GIT_TAG v3.0.0)
FetchContent_MakeAvailable(json)

# Compilation options
# Add an interface target for our header-only library
add_library(devdat INTERFACE)
target_include_directories(devdat INTERFACE
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  $<BUILD_INTERFACE:${json_SOURCE_DIR}/include/>
)

# compile the tests
include(CTest)
if(BUILD_TESTING)
  if(NOT TARGET Catch2)
    add_subdirectory(ext/Catch2)
    include(./ext/Catch2/contrib/Catch.cmake)
  endif()
  add_subdirectory(tests)
endif()


# Add an alias target for use if this project is included as a subproject in another project
add_library(devdat::devdat ALIAS devdat)

# Install targets and configuration
install(
  TARGETS devdat
  EXPORT devdat-config
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
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

install(FILES ${json_SOURCE_DIR}/include/nlohmann/json.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nlohmann/)

# This prints a summary of found dependencies
include(FeatureSummary)
feature_summary(WHAT ALL)
