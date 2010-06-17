#include "ruru.h"

#ifndef RU_MALLOC 
#define RU_MALLOC malloc
#endif
 
#ifndef RU_FREE 
#define RU_FREE free
#endif


RU_FUNC(RuRuntime*) ru_free(RuRuntime * self , void * pointer) {
  if (!self)    return self;
  if (!pointer) return self;
  RU_FREE(pointer);
  return self;  
}


RU_FUNC(void*)  ru_alloc(RuRuntime * self, RuSize size) {
  if (!self)    return NULL;
  return        RU_MALLOC(size);  
}


/* Initializes a runtime with the required parameters. */ 
RU_FUNC(RuRuntime *) ru_runtime_init(RuRuntime * self,
                                     RuAllocFunc a, 
                                     RuFreeFunc  f) {
  if (!self)    return self;
  self->alloc = ( a ? a : ru_alloc);
  self->free  = ( f ? f : ru_free );
  return self;
}


// Increases the reference count of a base object and returns it.
RU_FUNC(RuBase *)  ru_use(RuBase * self) {
  // Null objects are passed as is.
  if (!self) return self;
  // Objects with no free function do not participate in ref counting 
  if (self->free == 0) return self;
  // increase ref and return 
  self->refcount++;
  return self;
}


// Decreases a reference counf of a base object, possibly destroying it.
// Returns NULL.
RU_FUNC(RuBase *)  ru_toss(RuBase * self) {
  // Null objects are passed as is.
  if (!self)           return NULL;
  // Objects with no free function do not participate in ref counting 
  if (self->free == 0) return NULL;
  // Don't do anything if refcount is already 0
  if (self->refcount > 0) { 
    self->refcount--;
    if (self->refcount == 0) {
      self->free(self);
    }  
  }
  return NULL;
}

// The default runtime and a pointer to it
static RuRuntime default_runtime        = { ru_alloc, ru_free };
static RuRuntime * default_runtime_ptr  = &default_runtime;

/* Sets the default runtime. Returns last default runtime. NOT REENTRANT! */
RU_FUNC(RuRuntime *) ru_runtime_default_set(RuRuntime * self) {
  RuRuntime * old_runtime = default_runtime_ptr;
  default_runtime_ptr     = self;
  return  old_runtime;
}

/* Gets the default runtime. Returns last default runtime. NOT REENTRANT! */
RU_FUNC(RuRuntime *) ru_runtime_default_get(RuRuntime * self) {
  return  default_runtime_ptr;
}


// Initializes a basic object.
RU_FUNC(RuBase *)  ru_base_init(RuBase * b, RuRuntime * r,
				RuBaseFreeFunc f, RuSize s) {
  if (!b) return b;
  b->runtime	= r;
  b->free 	= ( f ? f : ru_base_free);
  b->size 	= s;
  b->refcount 	= 1;
}

// Frees a basic object only
RU_FUNC(RuBase *)  ru_base_free(RuBase * b) {
  if (!b) 	   	 return b;
  if (!b->runtime) 	 return b;
  if (!b->runtime->free) return b;
  RU_DO1(b->runtime, free, b);
  return NULL;
}

// Makes a basic object, allocating it.
RU_FUNC(RuBase *) ru_base_make(RuRuntime * r, RuBaseFreeFunc f, RuSize s) {
  RuBase * b;
  b = (RuBase *) RU_DO1(r, alloc, s);
  return ru_base_init(b, r, f, s);
}













