/** A simple generic queue using a ring buffer. */

#include <string.h>
#include "queue.h"


Queue * queue_init(Queue * queue, void * ptr, size_t cap, size_t sz) { 
  queue->buffer   = ptr;
  queue->bufend   = ((char *)queue->buffer) + (cap * sz);
  queue->head     = queue->buffer;
  queue->tail     = queue->buffer;  
  queue->capacity = cap;
  queue->isize    = sz;
  queue->count    = 0;  
  queue->error    = 0;
  return queue;
}


int queue_empty(Queue *queue) {
  return (queue->count == 0); 
}

int queue_full(Queue *queue) {
  return (queue->count == queue->capacity); 
}


Queue * queue_push(Queue * queue, const void *item) {
    if(queue_full(queue)) { // the queue is full
      // report error
      queue->error  = 1;
      return NULL; 
    }      
    // put item in head of queue
    memcpy(queue->head, item, queue->isize);
    // advance head 
    queue->head  = ((char*)queue->head) + queue->isize;
    // reset head if reached the end of the buffer
    if(queue->head == queue->bufend) { 
        queue->head = queue->buffer;
    }    
    queue->count++;
    return queue;
}

/**
* Shifts an item from the queue, copying it into the preallocated 
* location item which muct point to a location that has at least
* queue->isize space available;
*/
Queue * queue_shift(Queue *queue, void *item) {
    if(queue_empty(queue)) { 
      // report error
      queue->error  = 1;
      return NULL; 
    }
    // copy tail to item
    memcpy(item, queue->tail, queue->isize);
    // advance the tail of the queue
    queue->tail = ((char*)queue->tail) + queue->isize;
    // reset tail if it reached the end of the buffer
    if(queue->tail == queue->bufend) {
        queue->tail = queue->buffer;
    }    
    queue->count--;
}



