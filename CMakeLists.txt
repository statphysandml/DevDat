cmake_minimum_required(VERSION 3.18)
project(devdat VERSION 1.0.0 LANGUAGES CXX)

# Options
option(BUILD_TESTING "Build tests" ON)
option(DEVDAT_USE_SYSTEM_JSON "Use system-installed nlohmann_json" OFF)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Check for CUDA and enable it (required for Thrust)
include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
    enable_language(CUDA)
    set(CMAKE_CUDA_STANDARD 14)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)
    find_package(CUDAToolkit REQUIRED)
else()
    message(FATAL_ERROR "CUDA compiler not found! devdat requires CUDA for Thrust support.")
endif()

# Handle nlohmann_json dependency
if(DEVDAT_USE_SYSTEM_JSON)
    # Check if JSON_INCLUDE_DIR is provided by the superbuild
    if(DEFINED JSON_INCLUDE_DIR)
        message(STATUS "Using JSON include directory provided by superbuild: ${JSON_INCLUDE_DIR}")
        # Simple interface library to handle the include directory
        add_library(json_interface INTERFACE)
        target_include_directories(json_interface INTERFACE ${JSON_INCLUDE_DIR})
        set(JSON_TARGET json_interface)
    else()
        # Find system package
        message(STATUS "Finding system nlohmann_json package")
        find_package(nlohmann_json REQUIRED)
        set(JSON_TARGET nlohmann_json::nlohmann_json)
    endif()
else()
    # Fetch our own copy
    message(STATUS "Fetching nlohmann_json")
    include(FetchContent)
    FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.11.2
    )
    FetchContent_MakeAvailable(nlohmann_json)
    set(JSON_TARGET nlohmann_json::nlohmann_json)
    
    # Note: When not using system JSON, we'll need to ensure the headers are installed
    set(INSTALL_JSON_HEADERS TRUE)
endif()

# Create the library (header-only)
add_library(devdat INTERFACE)

# Set target properties
target_include_directories(devdat
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
)

# Link dependencies
target_link_libraries(devdat
    INTERFACE
        ${JSON_TARGET}
        CUDA::toolkit
)

# Add an alias target
add_library(${PROJECT_NAME}::devdat ALIAS devdat)

# Installation
include(GNUInstallDirs)
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

# Install the headers
install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# If we fetched JSON and need to install the headers
if(DEFINED INSTALL_JSON_HEADERS)
    install(
        DIRECTORY ${nlohmann_json_SOURCE_DIR}/include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

# Install the target
install(
    TARGETS devdat
    EXPORT ${PROJECT_NAME}Targets
)

# If using a custom JSON interface target, install it too
if(DEVDAT_USE_SYSTEM_JSON AND DEFINED JSON_INCLUDE_DIR)
    install(
        TARGETS json_interface
        EXPORT ${PROJECT_NAME}Targets
    )
endif()

# Export the targets
install(
    EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${INSTALL_CONFIGDIR}
)

# Create config files
include(CMakePackageConfigHelpers)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/devdatConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    @ONLY
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Install the config files
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)

# Add the tests if enabled
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()