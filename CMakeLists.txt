cmake_minimum_required(VERSION 3.18)
project(devdat VERSION 1.0.0 LANGUAGES CXX)

# Options
option(BUILD_TESTING "Build tests" ON)
option(DEVDAT_USE_SYSTEM_JSON "Use system-installed nlohmann_json" OFF)
# Add this to recognize the variable passed from superbuild
if(DEFINED USE_SYSTEM_JSON)
    set(DEVDAT_USE_SYSTEM_JSON ${USE_SYSTEM_JSON})
endif()

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
    message(STATUS "Using system JSON (DEVDAT_USE_SYSTEM_JSON=${DEVDAT_USE_SYSTEM_JSON})")
    
    if(DEFINED JSON_INCLUDE_DIR)
        message(STATUS "JSON_INCLUDE_DIR is set to: ${JSON_INCLUDE_DIR}")
        # Create a wrapper target that will be included in the export set
        add_library(devdat_json_wrapper INTERFACE)
        target_include_directories(devdat_json_wrapper INTERFACE 
            $<BUILD_INTERFACE:${JSON_INCLUDE_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        )
        set(JSON_TARGET devdat_json_wrapper)
        set(EXPORT_JSON_TARGET TRUE)
    else()
        # When using standard system package, handle dependency in config file
        find_package(nlohmann_json REQUIRED)
        set(JSON_TARGET nlohmann_json::nlohmann_json)
        # We'll handle this dependency in the config file
        set(EXPORT_JSON_TARGET FALSE)
    endif()
else()
    # Download nlohmann_json at configure time
    message(STATUS "Fetching nlohmann_json")
    include(FetchContent)
    FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.11.2
    )
    FetchContent_MakeAvailable(nlohmann_json)
    
    # Create our own interface that will be included in the export set
    add_library(devdat_json_wrapper INTERFACE)
    target_include_directories(devdat_json_wrapper INTERFACE 
        $<BUILD_INTERFACE:${nlohmann_json_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
    
    # Install the headers
    install(
        DIRECTORY ${nlohmann_json_SOURCE_DIR}/include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    
    set(JSON_TARGET devdat_json_wrapper)
    set(EXPORT_JSON_TARGET TRUE)
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

# Install headers
install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install targets - always install devdat
if(EXPORT_JSON_TARGET)
    # If we created our own JSON wrapper, install both together
    install(
        TARGETS devdat devdat_json_wrapper
        EXPORT ${PROJECT_NAME}Targets
    )
else()
    # Otherwise just install devdat
    install(
        TARGETS devdat
        EXPORT ${PROJECT_NAME}Targets
    )
endif()

# Export targets
install(
    EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${INSTALL_CONFIGDIR}
)

# Create config files
include(CMakePackageConfigHelpers)

# Create config file variables
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

# Install config files
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)

# Add tests if enabled
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()