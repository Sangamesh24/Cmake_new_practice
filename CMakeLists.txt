cmake_minimum_required(VERSION 3.10)
project(MyFirmware C)

set(CMAKE_C_STANDARD 11)

# Set toolchain if needed
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    # Uncomment below if using ARM
    # set(CMAKE_C_COMPILER arm-none-eabi-gcc)
    # set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
    find_program(CMAKE_OBJCOPY NAMES arm-none-eabi-objcopy objcopy)
endif()

add_executable(myfirmware.elf
    src/main.c
)

# Add custom command to generate .bin from .elf
add_custom_command(TARGET myfirmware.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary myfirmware.elf myfirmware.bin
    COMMENT “Generating .bin from .elf”
)
