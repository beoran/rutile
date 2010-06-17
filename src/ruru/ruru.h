/**
* Rutile runtime support.
* 
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef size_t RuSize;

/* 
  Some platforms will need a __declspec(dllexport or something for a 
  shared library.
*/
#ifndef RU_EXPORT_FUNC
#define RU_EXPORT_FUNC extern
#endif
  
/*
* Some platforms may require a change in calling convention
*/  
#ifndef RU_CALL_FUNC
#define RU_CALL_FUNC
#endif 

/* All in a handy wrapper macro */
#define RU_FUNC(RESULT) RU_EXPORT_FUNC RESULT RU_CALL_FUNC
 
/* An another wrapper macro to help typedefing such functions */
#define RU_FUNCTYPE(RESULT) typedef RESULT RU_CALL_FUNC  
 

/* Macros to make oop-style calls easier in handwritten code. */
#define RU_DO0(OBJ, FUNC)                               \
          (OBJ)->FUNC(OBJ)
#define RU_DO1(OBJ, FUNC, ARG1)                         \
          (OBJ)->FUNC(OBJ, ARG1)
#define RU_DO2(OBJ, FUNC, ARG1, ARG2)                   \
          (OBJ)->FUNC(OBJ, ARG1, ARG2)
#define RU_DO3(OBJ, FUNC, ARG1, ARG2, ARG3)             \
          (OBJ)->FUNC(OBJ, ARG1, ARG2, ARG3)
#define RU_DO4(OBJ, FUNC, ARG1, ARG2, ARG3, ARG4)       \
        (OBJ)->FUNC(OBJ, ARG1, ARG2, ARG3, ARG4)
#define RU_DO5(OBJ, FUNC, ARG1, ARG2, ARG3, ARG4, ARG5) \
        (OBJ)->FUNC(OBJ, ARG1, ARG2, ARG3, ARG4, ARG5)
#define RU_DO6(OBJ, FUNC, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6) \
        (OBJ)->FUNC(OBJ, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6) 

#define RU_STACKALLOC(PTR, SIZE) uint8_t PTR[SIZE]

struct RuRuntime_;

typedef struct RuRuntime_ RuRuntime;

RU_FUNCTYPE(RuRuntime *) (*RuFreeFunc) (RuRuntime *self, void * pointer);
RU_FUNCTYPE(void *)      (*RuAllocFunc)(RuRuntime *self, RuSize size);
 

// RuRuntimeInfo contains information of objects at runtime, so the object
// Does not have to track it itself.
struct RuRuntimeInfo_; 
typedef struct RuRuntimeInfo_ RuRuntimeInfo;


struct RuRuntime_ {
  RuAllocFunc alloc;
  RuFreeFunc  free;
};


/* Standard memory allocating function for runtime. */
RU_FUNC(void*)       ru_alloc(RuRuntime * self, RuSize size);

/* Standard memory freeing function for runtime. */
RU_FUNC(RuRuntime*)  ru_free(RuRuntime * self , void * pointer);

/* Initializes a runtime. */ 
RU_FUNC(RuRuntime *) ru_runtime_init(RuRuntime * self,
                                     RuAllocFunc a, 
                                     RuFreeFunc  f);

/* Sets the default runtime. Returns last default runtime. NOT REENTRANT! */
RU_FUNC(RuRuntime *) ru_runtime_default_set(RuRuntime * self);
/* Gets the default runtime. Returns last default runtime. NOT REENTRANT! */
RU_FUNC(RuRuntime *) ru_runtime_default_get(RuRuntime * self);


struct RuBase_;

typedef struct RuBase_ RuBase;

RU_FUNCTYPE(RuBase *) (*RuBaseFreeFunc) (RuBase *self);

typedef int32_t RuRefCount;
typedef int32_t RuBaseFlags;

/* A base Object */
struct RuBase_ {
  RuRuntime     * runtime;
  RuBaseFreeFunc  free;
  RuSize          size;
  // if size = 0 , the object was allocated from the stack or externally 
  // and needs not be freed
  RuRefCount      refcount;
  // Reference count 
};




// Initializes a basic object.
RU_FUNC(RuBase *)  ru_base_init(RuBase * b,  RuRuntime * r, 
				RuBaseFreeFunc f, RuSize s);

// Makes a basic object.
RU_FUNC(RuBase *)  ru_base_make(RuRuntime * r, RuBaseFreeFunc f, RuSize s);

// Frees a basic object only
RU_FUNC(RuBase *)  ru_base_free(RuBase * b);

// Increases the reference count of a base object and returns it.
RU_FUNC(RuBase *)  ru_use(RuBase * self);
// Decreases a reference counf of a base object, possibly destroying it
RU_FUNC(RuBase *)  ru_toss(RuBase * self);

















