add_library(ruru SHARED ruru.c)
# For testing
set (TEST_LIBS ${TEST_LIBS} ruru)
add_executable (ruru_test ruru_test.c)
target_link_libraries (ruru_test ${TEST_LIBS})
