/**
* Bybuf is a byte buffer with preallocated storage. 
*/

#ifndef _RTCUTL_BYBUF_H_
#define _RTCUTL_BYBUF_H_

#include "array.h"

struct Bybuf_;
typedef struct Bybuf_ Bybuf;

struct Bybuf_ {
  Array array;
};


/** Returns the capacity of the byte buffer. */
size_t bybuf_cap(Bybuf * bybuf);

/** Returns the length of the byte buffer. */
size_t bybuf_len(Bybuf * bybuf);


/** Initializes the byte buffer. */
Bybuf * bybuf_init(Bybuf * bybuf, void * storage, size_t cap);
 
/** Fills the byte buffer. */
Bybuf * bybuf_fill(Bybuf * bybuf, uint8_t byte); 

/**
* Stores a byte into the buffer at the given location. 
* Uses a int16_t, for symmetry with bybuf_getb.   
*/
Bybuf * bybuf_setb(Bybuf * bybuf, int index, int16_t byte);

/** Gets a byte from the buffer. Returns -1 on error.
* Hence, it returns an int16_t, not an int8_t; 
*/
int16_t bybuf_getb(Bybuf * bybuf, int index);






#endif


