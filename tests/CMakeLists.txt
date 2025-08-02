include(FetchContent)

FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        v2.13.8
)
FetchContent_MakeAvailable(Catch2)

add_executable(devdat_tests tests.cpp devdat_t.cu)

target_include_directories(devdat_tests
    PRIVATE
        ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
)

target_link_libraries(devdat_tests
    PRIVATE
    devdat
    Catch2::Catch2
)

include(${catch2_SOURCE_DIR}/contrib/Catch.cmake)
catch_discover_tests(devdat_tests)