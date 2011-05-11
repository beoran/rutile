cmake_minimum_required(VERSION 2.6)
add_library(ruru SHARED ruru.c)
# For testing
link_directories(.)
set(LIBRARY_LIST m pthread)
set (TEST_LIBS ${LIBRARY_LIST} ruru)
add_executable (ruru_test ruru_test.c)
target_link_libraries (ruru_test ${TEST_LIBS})






