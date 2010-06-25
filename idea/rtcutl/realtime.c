/* 
  Functions that enable relatime performance in Linux. 
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h> // Needed for mlockall()
#include <unistd.h> // needed for sysconf(int name);
#include <malloc.h>
#include <sys/time.h> // needed for getrusage
#include <sys/resource.h> // needed for getrusage
#include <sched.h> //needed for rt scheduling
#include <limits.h> // needed for PTHREAD_STACK_MIN
#include <pthread.h>
#include "realtime.h"

#define RT_MEMORY_SIZE ( 100 * 1024 * 1024 ) /* Memory size of heap and stack. */
#define RT_STACK_SIZE  ( 100 * 1024 )        /* 100 kB stack size for now.     */

// Gets the lowest possible prioriy that can be used for 
// rt_realtime_priority_thread or rt_realtime_priority  
int realtime_priority_min() {
  return sched_get_priority_min(SCHED_RR);
}  

// Gets the highest possible priority that can be used for 
// rt_realtime_priority_thread or rt_realtime_priority  
int realtime_priority_max() {   
  return sched_get_priority_max(SCHED_RR);
}  

// Set realtime priority for the thread with thread id id.
// If priority is 0, rt_realtime_priority_min() is called and it's value
// is used as the default.
// If id is 0 , realtime priority is set for the current thread. 
int realtime_priority_thread(int priority, int id) {
  struct sched_param param;
  priority = ( priority > 0 ? priority : realtime_priority_min());
  param.sched_priority = priority ;
  return sched_setscheduler(id, SCHED_RR, &param);
}


// Set realtime priority for this thread. If priority is 0, 
// sched_get_priority_min(SCHED_RR)
int realtime_priority(int priority) {
  realtime_priority_thread(priority, 0);
}



// Starts a thread in such a way it can be run with real time priority.
// Don' t forget to call rt_realtime_opriority at the beginning of the thread 
// function.
// Func is the function that will be run inside the thread.
// stacksize is the stack size to use. If you pass 0 , 
// it will be filled in automatically with  RT_STACK_SIZE
// If the value you pass in is too small, it will be adjusted to the OS's 
// minimum size.
   
int realtime_thread_start(RtThreadFunc func, size_t stacksize, void * args) {
  int err;
  pthread_t      thread;
  pthread_attr_t attr;
  /* Choose acceptable stack size. */
  stacksize = ( stacksize >  0  ? stacksize : RT_STACK_SIZE );
  stacksize = ( stacksize < PTHREAD_STACK_MIN ? PTHREAD_STACK_MIN : stacksize);    
  /* Init to default values */
  if (err = pthread_attr_init(&attr)) { return err; } 
  if (err = pthread_attr_setstacksize(&attr, stacksize)) {
    return err;
  }
  /* And finally start the actual thread */
  pthread_create(&thread, &attr, func, args);
}


static void realtime_show_rusage() {
  struct rusage usage;
  getrusage(RUSAGE_SELF, &usage);
  printf("Major Page Faults:%ld, Minor Page Faults:%ld\n", 
    usage.ru_majflt, usage.ru_minflt);
}

/* 
  Prepares the application's current and future memory for real time use
  by locking it , disallowing it to be paged to hard disk.
  memory_size: the amount of memory in bytes to try and lock. 
  if this is 0, RT_MEMORY_SIZE (100MB) will be used as a default. 
*/
int realtime_prepare_memory(size_t memory_size) {
  int    err, i;
  size_t page_size;
  char * buffer;
  memory_size = (memory_size > 0 ? memory_size : RT_MEMORY_SIZE); 
  // Turn off malloc trimming.
  mallopt (M_TRIM_THRESHOLD, -1);
  // Turn off mmap usage.
  mallopt (M_MMAP_MAX, 0);
  // get page size
  page_size   = sysconf(_SC_PAGESIZE);
  // Allocate a buffer of the requested size to lock
  buffer      = malloc(memory_size);
  // Now lock all current and future pages from preventing of being paged
  if (err     = mlockall(MCL_CURRENT | MCL_FUTURE) ) {
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



