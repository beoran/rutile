#include "bybuf.h"

/* Helper function for forwarding and delegating to Array. */
Bybuf * bybuf_fwd(Bybuf * bybuf, void * result) {
  if (result) { return bybuf; } 
  return NULL; 
} 

/* Returns the address of the array inside the Bytebuf */
Array * bybuf_arr(Bybuf * bybuf) {   
  return &bybuf->array; 
} 


/** Returns the capacity of the byte buffer. */
size_t bybuf_cap(Bybuf * bybuf) {
  return array_cap(bybuf_arr(bybuf));
}

/** Returns the length of the byte buffer. */
size_t bybuf_len(Bybuf * bybuf) {
  return array_len(bybuf_arr(bybuf));
}


/** Initializes the byte buffer. */
Bybuf * bybuf_init(Bybuf * bybuf, void * storage, size_t cap) {
  return bybuf_fwd(bybuf, array_init(bybuf_arr(bybuf), storage, cap, 1)); 
}

/** Fills the byte buffer. */
Bybuf * bybuf_fill(Bybuf * bybuf, uint8_t byte) {
  return bybuf_fwd(bybuf, array_fill(bybuf_arr(bybuf), &byte));   
}

/**
* Stores a byte into the buffer at the given location. 
* Uses a int16_t, for symmetry with bybuf_getb.   
*/
Bybuf * bybuf_setb(Bybuf * bybuf, int index, int16_t byte) {
  uint8_t realbyte;
  if (byte < 0)  { return NULL; } 
  if (byte > 255){ return NULL; }
  realbyte = (uint8_t)(byte);
  return bybuf_fwd(bybuf, array_set(bybuf_arr(bybuf), index, &realbyte));
}

/** Gets a byte from the buffer. Returns -1 on error.
* Hence, it returns an int16_t, not an int8_t; 
*/
int16_t bybuf_getb(Bybuf * bybuf, int index) {
  uint8_t byte;
  if ( array_get(bybuf_arr(bybuf), index, &byte) ) {
    return byte;
  }
  return -1;
}














