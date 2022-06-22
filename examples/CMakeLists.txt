add_executable(devdat_examples src/devdat_t.cu src/random.cu main.cpp)
target_link_libraries(devdat_examples PRIVATE devdat)

target_include_directories(devdat_examples PUBLIC
    $<BUILD_INTERFACE:${json_SOURCE_DIR}/include/>
)