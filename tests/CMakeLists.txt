add_executable(devdat_tests tests.cpp devdat_t.cu)
target_link_libraries(devdat_tests PUBLIC devdat Catch2::Catch2)

target_include_directories(devdat_tests PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}>
    $<BUILD_INTERFACE:${json_SOURCE_DIR}/include/>
)

# allow user to run tests with `make test` or `ctest`
catch_discover_tests(devdat_tests)
