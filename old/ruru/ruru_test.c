#include "ruru.h"
#include "test.h"
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/mman.h> // Needed for mlockall()
#include <unistd.h> // needed for sysconf(int name);
#include <malloc.h>
#include <sys/time.h> // needed for getrusage
#include <sys/resource.h> // needed for getrusage
#include <sched.h> //needed for rt scheduling
#include <limits.h> // needed for PTHREAD_STACK_MIN
#include <pthread.h>

#define RT_MEMORY_SIZE ( 100 * 1024 * 1024 ) /* Memory size of heap and stack. */
#define RT_STACK_SIZE  ( 100 * 1024 )        /* 100 kB stack size for now.     */

#define DEFAULT_REALTIME_PRIORITY (sched_get_priority_min(SCHED_RR))

// Set realtime priority for this thread
int rt_realtime_priority(int priority) {
  struct sched_param param;
  priority = ( priority > 0 ? priority : sched_get_priority_min(SCHED_RR));
  param.sched_priority = priority ;
  return sched_setscheduler(0, SCHED_RR, &param);
}

typedef void * (*RtThreadFunc) (void * args);

int rt_thread_start(RtThreadFunc func) {
  int err;
  pthread_t      thread;
  pthread_attr_t attr;
  /* Init to default values */
  if (err = pthread_attr_init(&attr)) { return err; } 
  if (err = pthread_attr_setstacksize(&attr, PTHREAD_STACK_MIN + RT_STACK_SIZE)) {
    return err;
  }
  /* And finally start the actual thread */
  pthread_create(&thread, &attr, func, NULL);
}


void rt_show_rusage() {
  struct rusage usage;
  getrusage(RUSAGE_SELF, &usage);
  printf("Major Page Faults:%ld, Minor Page Faults:%ld\n", 
	  usage.ru_majflt, usage.ru_minflt);
}

int rt_prepare_memory() {
  int    err, i;
  size_t page_size;
  char * buffer;
  // Turn off malloc trimming.
  mallopt (M_TRIM_THRESHOLD, -1);
  // Turn off mmap usage.
  mallopt (M_MMAP_MAX, 0);
  page_size 	= sysconf(_SC_PAGESIZE);
  buffer	= malloc(RT_MEMORY_SIZE);
  // Now lock all current and future pages from preventing of being paged
  if (err 	= mlockall(MCL_CURRENT | MCL_FUTURE) ) {
    return err;
  }
  // Touch each page in this piece of memory to get it mapped into RAM
  for( i = 0 ; i < RT_MEMORY_SIZE ; i += page_size) {
    // Each write to this buffer will generate a pagefault.
    // Once the pagefault is handled a page will be locked in memory and never
    // given back to the system.
    buffer[i] = 0;
    // print the number of major and minor pagefaults this application has triggered
    // rt_show_rusage();
  }
  free(buffer);
  // buffer is now released. As glibc is configured such that it never gives back memory to
  // the kernel, the memory allocated above is locked for this process. All malloc() and new()
  // calls come from the memory pool reserved and locked above. Issuing free() and delete() does NOT make this locking undone. 
  return 0;
}




int main(void) {
  int err = rt_prepare_memory();
  if (err) {   perror("Failed to lock memory: "); }   
  err     = rt_realtime_priority(5);
  if (err) {   perror("Failed to set realtime priority: "); }   
  TEST_INIT(test);
  RuRuntime * runtime;
  RU_STACKALLOC(pruntime, sizeof(RuRuntime));
  runtime = ru_runtime_default_get(NULL);
  //  (RuRuntime *) pruntime;
  void * block;  
  ru_runtime_init(runtime, ru_alloc, ru_free);
  RuBase * base;
  base  = ru_base_make(runtime, ru_base_free, sizeof(RuBase));
  ru_use(base);
  block = RU_DO1(runtime, alloc, 123);
  printf("%p %p\n", block, pruntime);
  printf("%p %d\n", base, base->refcount);
  RU_DO1(runtime, free, block);  
  ru_toss(base);
  ru_toss(base);
  TEST_REPORT(test);
  return 0;
}









