cmake_minimum_required(VERSION 3.8...3.20)

project(fso VERSION 1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)

include_directories(lua/include)
link_directories(lua/lib)
# for shared library DLL platform
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY fso/output)
# for shared non-DLL platform 
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY fso/output)

add_library(fso SHARED src/fso.cpp)
target_link_libraries(fso PRIVATE lua)
set_target_properties(fso PROPERTIES PREFIX "")



