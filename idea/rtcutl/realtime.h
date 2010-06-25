#ifndef _REALTIME_H_
#define _REALTIME_H_

#include <stdlib.h>

/* Functions that enable relatime performance in Linux. */

/* 
  Prepares the application's current and future memory for real time use
  by locking it , disallowing it to be paged to hard disk.
  memory_size: the amount of memory in bytes to try and lock. 
  if this is 0, RT_MEMORY_SIZE (100MB) will be used as a default.
  You should call this function before any memory is allocated dynamically. 
*/
int rt_prepare_memory(size_t memory_size);

typedef void * (*RtThreadFunc) (void * args);


// Gets the lowest possible prioriy that can be used for 
// rt_realtime_priority_thread or rt_realtime_priority  
int realtime_priority_min();

// Gets the highest possible priority that can be used for 
// rt_realtime_priority_thread or rt_realtime_priority  
int realtime_priority_max(); 

// Set realtime priority for the thread with thread id id.
// If priority is 0, rt_realtime_priority_min() is called and it's value
// is used as the default.
// If id is 0 , realtime priority is set for the current thread. 
int realtime_priority_thread(int priority, int id);


// Set realtime priority for the current thread. If priority is 0, 
// it is set to the minimal realtime mriority.
int realtime_priority(int priority);


// Starts a thread in such a way it can be run with real time priority.
// You should call rt_realtime_opriority at the beginning of the thread 
// function.
// Func is the function that will be run inside the thread.
// stacksize is the stack size to use. If you pass 0 , 
// it will be filled in automatically with  RT_STACK_SIZE
// If the value you pass in is too small, it will be adjusted to the OS's 
// minimum size.
int realtime_thread_start(RtThreadFunc func, size_t stacksize, void * args);

/* 
  Prepares the application's current and future memory for real time use
  by locking it , disallowing it to be paged to hard disk.
  memory_size: the amount of memory in bytes to try and lock. 
  if this is 0, RT_MEMORY_SIZE (100MB) will be used as a default. 
*/
int realtime_prepare_memory(size_t memory_size);

#endif


