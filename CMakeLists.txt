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
    find_package(nlohmann_json REQUIRED)
    set(JSON_TARGET nlohmann_json::nlohmann_json)
else()
    # Download nlohmann_json at configure time
    include(FetchContent)
    FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.11.2
    )
    FetchContent_MakeAvailable(nlohmann_json)
    
    # Create our own interface that doesn't need to be exported
    add_library(devdat_json_dep INTERFACE)
    target_include_directories(devdat_json_dep 
        INTERFACE 
            $<BUILD_INTERFACE:${nlohmann_json_SOURCE_DIR}/include>
            # Important: This is how consumers will find the headers
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
    
    # Install the nlohmann_json headers directly to include directory
    # This ensures they're found alongside our own headers
    install(
        DIRECTORY ${nlohmann_json_SOURCE_DIR}/include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    
    set(JSON_TARGET devdat_json_dep)
endif()

# Create the library (header-only)
add_library(devdat INTERFACE)

# Set target properties (note: header-only libraries use INTERFACE)
target_include_directories(devdat
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        $<BUILD_INTERFACE:${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}>
        $<INSTALL_INTERFACE:${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}>
)

# Link dependencies (using our local target and CUDA)
target_link_libraries(devdat
    INTERFACE
        ${JSON_TARGET}
        CUDA::toolkit
)

# Add an alias target for use within the build tree
add_library(${PROJECT_NAME}::devdat ALIAS devdat)

# Installation
include(GNUInstallDirs)
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

# Install the headers
install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install the target (note: header-only libraries have special install syntax)
install(
    TARGETS devdat
    EXPORT ${PROJECT_NAME}Targets
)

if(NOT DEVDAT_USE_SYSTEM_JSON)
    # Add our bundled dependency to the exported targets
    install(
        TARGETS devdat_json_dep
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

# Create a config file that handles dependencies
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/DevdatConfig.cmake.in
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