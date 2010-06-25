cmake_minimum_required(VERSION 2.6)
#set(LIBS ${LIBS} pthread m)
# Real Time enabled C Utility Library
add_library(rtcutl STATIC array.c bybuf.c stick.c queue.c fiso.c log.c realtime.c)
target_link_libraries(rtcutl ${LIBS})
set(TEST_LIBS ${LIBS} rtcutl) 
add_executable(rtcutl_test rtcutl_test.c)
target_link_libraries(rtcutl_test ${TEST_LIBS})
enable_testing()
set(RTCUTL_TEST ${EXECUTABLE_OUTPUT_PATH}rtcutl_test) 
add_test(rtcutl_test ${RTCUTL_TEST})
# Make sure that ctest shows the test error messages if there are any.
set(CMAKE_CTEST_OPTIONS --output-on-failure)
# Make check compiles the tests and runs them immediately.
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} ${CMAKE_CTEST_OPTIONS} DEPENDS ${RTCUTL_TEST})


add_executable(rtcutl_spec rtcutl_spec.c)
target_link_libraries(rtcutl_spec ${TEST_LIBS})
set(RTCUTL_SPEC ${EXECUTABLE_OUTPUT_PATH}rtcutl_spec)
# Make spec compiles the specs and runs them immediately.
add_custom_target(spec COMMAND ${RTCUTL_SPEC} DEPENDS ${RTCUTL_SPEC})

