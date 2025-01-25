cmake_minimum_required(VERSION 3.10)

project(macos-clip-sync)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_library(ApplicationServices_FRAMEWORK ApplicationServices)
find_library(CoreFoundation_FRAMEWORK CoreFoundation)

# Find Boost library (Asio part)
find_package(Boost REQUIRED)
if(Boost_FOUND)
    message(STATUS "Boost found: ${Boost_INCLUDE_DIRS}")
else()
    message(FATAL_ERROR "Boost not found!")
endif()

find_package(X11 REQUIRED)

set(SOURCES
    src/main.mm
    src/OsxClipboard.mm
    src/X11Clipboard.mm
)

add_executable(${PROJECT_NAME} ${SOURCES})

target_link_libraries(${PROJECT_NAME} PRIVATE
    ${ApplicationServices_FRAMEWORK} 
    ${CoreFoundation_FRAMEWORK}
    ${Boost_LIBRARIES}
)

target_include_directories(${PROJECT_NAME} PRIVATE 
    ${Boost_INCLUDE_DIRS}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    X11::X11
    X11::Xfixes
)

target_include_directories(${PROJECT_NAME} PRIVATE 
    ${X11_X11_INCLUDE_PATH}
    ${X11_Xfixes_INCLUDE_PATH}
)

