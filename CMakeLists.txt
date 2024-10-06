
cmake_minimum_required(VERSION 3.15)
project(OpTests)
find_package(OpenCV REQUIRED)
add_executable(OpTests src/photo_scanner.cpp)
target_link_libraries(OpTests PRIVATE
    ${OpenCV_LIBS}
)