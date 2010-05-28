#include <stdio.h>
#include <stdlib.h>
#include <string.h>


struct Arr {
  int data[10];
  int size;
};


struct RU_Thing_;
struct RU_Fail_;
struct RU_Block_;

#ifndef ru_malloc
  #define ru_malloc(size) malloc(size)
#endif

#ifndef ru_free
  #define ru_free(ptr) free(ptr)
#endif
  

typedef struct RU_Block_        RU_Block;
typedef struct RU_Block_      * RU_Block_Ptr;
typedef struct RU_Fail_         RU_Fail;
typedef struct RU_Fail_       * RU_Fail_Ptr;
typedef struct RU_Thing_        RU_Thing; 

typedef void (*RU_Thing_Free)(RU_Thing * thing);

enum RU_Thingtag_ { 
  RU_THINGTAG_STATIC = 1, RU_THINGTAG_ALLOCATED = 2 
};

typedef enum RU_Thingtag_ RU_Thingtag;

struct RU_Thing_ {
  RU_Thingtag        tag;
  size_t             refc;
  struct RU_Thing_ * self;
  struct RU_Thing_ * parent;  
  RU_Thing_Free      free;
};


void ru_thing_free(RU_Thing * thing) {
  if(thing->tag | RU_THINGTAG_STATIC) return;
  // Do not deallocate statically allocated data.
    
  if(!thing)      return;
  if(!thing->self) return;
  
  if(thing->parent) {
    thing->parent->free(thing->parent);
  } else { 
    ru_free(thing);
  }  
  thing->self    = NULL;
  thing->parent  = NULL;
}



enum RU_Failcode_ { RU_FAIL_OK, RU_FAIL_ERROR, RU_FAIL_FATAL };
typedef enum   RU_Failcode_     RU_Failcode;

struct RU_Fail {
  RU_Thing    object;
  RU_Failcode fail;
};

enum RU_Blockresult_ { RU_BLOCK_YIELD, RU_BLOCK_FINISH };
typedef enum   RU_Blockresult_  RU_Blockresult;

typedef RU_Blockresult (*RU_Block_Function) (RU_Block * self);


struct RU_Block_ {
  struct RU_Fail fail;
  RU_Block_Function call;
};


struct block_data_1;

struct block_data_1 {
  RU_Block block;
  int index;
  int value;
  struct Arr * arr;  
};

typedef struct block_data_1 block_data_1;

 
RU_Blockresult ru_block_call(RU_Block *block) {
  return block->call(block);
}

static RU_Blockresult block_func_1(block_data_1 * self) {
  if(!self) return RU_BLOCK_FINISH;
  if(self->index == self->arr->size) { return RU_BLOCK_FINISH; }
  /** 
   Here real block inner...   
  */
  printf("%d: %d\n", self->index, self->arr->data[self->index]);
  self->index++;
  return RU_BLOCK_YIELD;
}



int main() {
  struct Arr arr;  
  struct block_data_1 block;
  int i;
  
  arr.size    = 10;
  block.arr   = &arr;
  
  for(i = 0; i < 10; i++) { block.arr->data[i] = 10 - i; } 
  block.index = 0;
  block.block.call = (RU_Block_Function) block_func_1;
  
  while (ru_block_call((RU_Block *)&block) != RU_BLOCK_FINISH) {
    puts("Called");
  }
  

  puts("OK");
  return 0;
}

