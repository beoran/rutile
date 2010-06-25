/** Generic queue. Uses a ring buffer which should be preallocated by the user of the queue. */

#ifndef _RTCUTL_QUEUE_H_
#define _RTCUTL_QUEUE_H_

#include <stdlib.h>

struct Queue_;
typedef struct Queue_ Queue;

struct Queue_ {
    void *buffer;     // data buffer
    void *bufend;     // end of data buffer
    void *head;       // pointer to head
    void *tail;       // pointer to tail
    size_t capacity;  // maximum number of items in the buffer
    size_t count;     // number of items in the buffer
    size_t isize;     // size of each item in the buffer
    int error;        // last error
};

/** 
* Initializes a queue
* ptr should be the preallocated buffer to use, cap is the amount of items
* that can be stored,and sz is thee size of the individual items. 
*/
Queue * queue_init(Queue * queue, void * ptr, size_t cap, size_t sz);

/** 
  Returns nonzero if the queue is empty, zero if the 
  queue has some items in it.
*/   
int queue_empty(Queue *queue);

/** 
* Returns nonzero if the queue is full, zero if the 
* queue still has space left.
**/ 
int queue_full(Queue *queue); 

/** 
* Pushes an item into the queue. The item will be copied.
*/ 
Queue * queue_push(Queue * queue, const void *item); 

/**
* Shifts an item from the queue, copying it into the preallocated 
* location item which must point to a location that has at least
* queue->isize space available;
*/
Queue * queue_shift(Queue *queue, void *item); 



#endif
