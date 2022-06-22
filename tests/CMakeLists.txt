add_executable(tests tests.cpp devdat_t.cpp)
target_link_libraries(tests PUBLIC devdat Catch2::Catch2)

target_include_directories(tests PUBLIC
    $<BUILD_INTERFACE:${json_SOURCE_DIR}/include/>
)

# allow user to run tests with `make test` or `ctest`
catch_discover_tests(tests)
