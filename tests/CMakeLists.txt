# Enable testing
enable_testing()

# Unit test executable
add_executable(unit_tests
    tests/test_main.c
)

# Include Unity headers (adjust path if necessary)
target_include_directories(unit_tests PRIVATE tests)

# Link any required libraries
# target_link_libraries(unit_tests myfirmware_lib)

# Register the test
add_test(NAME UnitTests COMMAND unit_tests)
