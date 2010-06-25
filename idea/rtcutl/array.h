
#ifndef _RTCUTL_ARRAY_H_
#define _RTCUTL_ARRAY_H_

#include <stdlib.h>
#include <stdint.h>
#include <string.h>


/** Array is a generic array type that uses a preallocated buffer.
* All elements must be of a predefined size.  
*/
struct Array_;
typedef struct Array_ Array;

struct Array_ {
  uint8_t *ptr;
  size_t   len;
  size_t   cap;
  size_t   esz;
};

/**
* Initializes an empty array, using the given buffer ptr as storage.
* ptr points to an area of memory that has at least a capacity to store
* cap items of esz size each.
*/
Array * array_init(Array * array, void * ptr, size_t cap, size_t esz);

/** Returns the length of the array.  */
size_t array_len(Array * array);

/** Returns the capacity of the array.  */
size_t array_cap(Array * array);

/** Returns the pointer of the array as a (void *) pointer */
void * array_ptr(Array * array);


/** Returns a pointer offset, taking element size into consideration */
uint8_t * array_offset(Array * array, uint8_t * ptr, int index); 

/** 
* Copies len elements from ptr into the array, starting from 
* pstart, and astart as long as there is enough capacity in the array 
* to do so, and if it would not meean exeeding plen 
* do so.
*/
Array * array_xmemcpy(Array *arr, const void * ptr, size_t len, 
                      int astart, int pstart, size_t plen); 
/**
* Copies a C array from a memory location into the Array.
*/
Array * array_memcpy(Array * arr, const void * ptr, size_t plen); 


/** Sets a value in the array at the given index.
* Returns null if it is out of range, returns array of all was ok. 
*/
Array * array_set(Array * array, int index, const void *item);

/** 
* Gets a value in the array at the given index, and stores it in 
* item.
* Returns null if it is out of range, returns array of all was ok. 
*/
Array * array_get(Array * array, int index, void *item);


/** Truncates an array to the given length by resetting it's length.
* Does not affect capacity. 
*/
Array * array_trunc(Array * array, int size);

/** Concatenates arrays together. dst will be modified if it's capacity 
* allows it. Arrays must have same element size. 
*/
Array * array_cat(Array * dst, Array * src);

/** 
* Fills an array upto it's capacity with the given pointed to value.
* The array's length will be set 
*/
Array * array_fill(Array * array, void * item);

#endif

