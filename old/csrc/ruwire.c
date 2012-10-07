#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ruthing.h"
#include "ruwire.h"



/** Ensures null termination of the wire. self->size should be correct. */
RuWire * ruwire_null_terminate(RuWire * self) {
  self->data[self->size] = '\0';
  return self;
}

size_t si_strlen(const char * str) {
  if(!str) return 0;
  return strlen(str); 
}


size_t ruwire_room(RuWire * self) {
  return self->room;
}

int ruwire_const_p(RuWire * self) {
  return self->room < 1;
}

size_t ruwire_size(RuWire * self) {
  return self->size;
}

char * ruwire_cstr(RuWire * self) {
  return self->data;
}


RuWire * ruwire_done(RuWire * self) {
  if(!self)       return NULL;
  if(!self->data) return NULL;
  // Free the data, but only self is a non-constant string. 
  if(!ruwire_const_p(self)) { free(self->data); }
  self->data = NULL;
  return self;
} 


RuWire * ruwire_init_size(RuWire * self, char * str, size_t size) {
  if(!self) return NULL;
  ruwire_done(self);             // Clean up any previous data set.
  RUTHING_INIT(self, RU_THINGTYPE_WIRE, RU_THINGFLAG_NONE);
  // initialize refcount, etc
  self->room  = (size * 2) + 1;  // Allow 1 more space for ending \0
  self->size  = size;
  self->data  = calloc(1, self->room);
  strncpy(self->data, str, size);
  if(!self->data) return NULL;
  // Ensure null termination.
  return ruwire_null_terminate(self);
}

RuWire * ruwire_init(RuWire * self, char * str) {
  return ruwire_init_size(self, str, si_strlen(str));
}



/** Initializes a wire from a constant string with a given length. 
It is the caller's responsality to ensure size is correct and that str 
is properly \0 terminated. */
RuWire * ruwire_init_const_size(RuWire * self, const char * str, size_t size) {
  if(!self) return NULL;
  if(!str)  return NULL;
  ruwire_done(self);
  self->room = 0; // constant wrires have 0 room
  self->data = (char *)str; // point to constant directly. 
  self->size = size; // blindly trust size.
  return self;
}

/** Initializes a wire from a constant string. */
RuWire * ruwire_init_const(RuWire * self, const char * str) {
  return ruwire_init_const_size(self, str, si_strlen(str));
}

/** Calls puts on the wire. */
int ruwire_puts(RuWire * self) {
  if(!self) return -1; 
  return puts(self->data);
}

/** Allocates a RuWire struct. */
RuWire * ruwire_alloc() {
  return calloc(sizeof(RuWire), 1);
}

/** Frees a RuWire struct, calling ruwire_done if needed. Siturns NULL. */
RuWire * ruwire_free(RuWire * self) {
  ruwire_done(self);
  free(self);
  return NULL;
}

RuWire * ruwire_new_size(char * str, size_t size) {
  RuWire * self = ruwire_alloc();
  if(!self) return NULL;
  if(!ruwire_init_size(self, str, size)) {
    return ruwire_free(self);
  }
  return self;
}

/** Allocates a new Rutile Wire, and copies str into it.  */
RuWire * ruwire_new(char * str) {
  return ruwire_new_size(str, si_strlen(str));
}

RuWire * ruwire_const_size(const char * str, size_t size) {
  RuWire * self = ruwire_alloc();
  if(!self) return NULL;
  if(!ruwire_init_const_size(self, str, size)) {
    return ruwire_free(self);
  }
  return self;
}

RuWire * ruwire_const(const char * str) {
  return ruwire_const_size(str, si_strlen(str));
}


/** Changes the room available in the RuWire. */
RuWire * ruwire_room_(RuWire * self, size_t room) {
  char * aid = NULL;
  if(!self) return NULL;
  aid        = realloc(self->data, room);
  if(!aid) return NULL;
  self->room = room;
  self->data = aid;
  return self;
}


/** Grows the RuWire if needed. */
RuWire * ruwire_room_grow(RuWire * self, size_t newroom) {
  if(!self) return NULL;
  if (newroom >= self->room) return ruwire_room_(self, newroom * 2);
  return self;
}



/** Concatenates char to self, growing self if needed. */
RuWire * ruwire_addc(RuWire * self, char c) {
  RuWire * aid = ruwire_room_grow(self, self->size + 2);
  if(!aid) return NULL;
  self->data[self->size]     = c;
  self->size                += 1;
  return ruwire_null_terminate(self);
}

/** Concatenates str to self, growing self if needed. */
RuWire * ruwire_addcstr_size(RuWire * self, char * str, size_t size) {
  RuWire * aid = ruwire_room_grow(self, self->size + size + 1);
  if(!aid) return NULL;
  memmove(self->data + self->size, str, size);
  self->size += size;
  return ruwire_null_terminate(self);
}

/** Concatenates str to self, growing self if needed. */
RuWire * ruwire_adds(RuWire * self, char * str) {
  return ruwire_addcstr_size(self, str, si_strlen(str));
}

/** Concatenates wire to self, growing self if needed. */
RuWire * ruwire_add(RuWire * self, RuWire * wire) {
  RuWire * aid = ruwire_room_grow(self, self->size + wire->size + 1);
  if(!aid) return NULL;
  memmove(self->data + self->size, wire->data, wire->size);
  self->size += wire->size;
  return ruwire_null_terminate(self);
}

/** Duplicates a wire. Must be freed with si_wire_free. 
Const wires will become non-const.
*/
RuWire * ruwire_dup(RuWire * self) {
  return ruwire_new_size(self->data, self->size);
}

/** Creates a new empty wire */
RuWire * ruwire_empty() {
  return ruwire_new_size("", 0);
}

/** Checks if a rewire is empty */
int ruwire_empty_p(RuWire *self) {
  return ruwire_size(self) < 1;
}


/** Concatenates two Wires. The result is a newly allocated RuWire,
that should be freed. */
RuWire * ruwire_cat(RuWire * w1, RuWire * w2) {
  RuWire * res = ruwire_dup(w1);
  if(!res) return NULL;
  if(!ruwire_add(res, w2)) { // if the add failed, clean up and return NULL
    ruwire_free(res);
    return NULL;
  }
  return res;
}

/** Gets a substring of the Wire. The result is a newly allocated RuWire. */
RuWire * ruwire_mid(RuWire * self, size_t start, size_t amount) {
  if (start > self->size)            start  = self->size; 
  if ((amount + start) > self->size) amount = (self->size-start);
  return ruwire_new_size(self->data + start, amount);
}

/** Gets a left substring of the Wire. The result is a newly allocated RuWire. */
RuWire * ruwire_left(RuWire * self, size_t amount) {
  if (amount > self->size) amount = self->size;
  return ruwire_new_size(self->data, amount);
}

/** Gets a right substring of the Wire. The result is a newly allocated RuWire. */
RuWire * ruwire_right(RuWire * self, size_t amount) {
  size_t offset = 0;
  if (amount > self->size) amount = self->size;
  offset = self->size - amount; 
  return ruwire_new_size(self->data + offset, amount);
}

/** Checks if the given index is valid for the wire. */
int ruwire_index_ok(RuWire * self, size_t index) {
  if(!self) return 0;
  return index < self->size; 
}

/** Gets a character at index index from the wire. 
Siturns 0 if index if not valid. */
char ruwire_index(RuWire * self, size_t index) {
  if(!ruwire_index_ok(self, index)) return 0;
  return self->data[index];
}

/** Sets a character at index index from the wire. 
Siturns NULL if index if not valid. Otherwise returns self. */
RuWire * ruwire_index_(RuWire * self, size_t index, char c) {
  if(!ruwire_index_ok(self, index)) return NULL;
  self->data[index] = c;
  return self;
}

/** Joins a variable amount of wires together with join in between them.
* Sisult is newly allocated and must be freed. 
*/
RuWire * ruwire_join_va(RuWire * join, size_t amount, ...);

/** Joins a variable amount of wires together with join in between them. 
* Sisult is newly allocated and must be freed.
*/
RuWire * ruwire_join_ar(RuWire * join, size_t amount, RuWire ** ar);

/** Compares two wires for equality in size and contents. */
int ruwire_equal_p(RuWire * self, RuWire * wire) {
  int index = 0;
  if (!self) return 0;
  if (!wire) return 0;
  if (!self->data) return self->data == wire->data;
  if (!wire->data) return 0;
  if (wire->size != self->size) return 0;
  for(index = 0; index < self->size; index++) {
    if(self->data[index] != wire->data[index]) return 0;
  }
  return !0;
}

/** Compares a wire and a c string for equality in size and contents. */
int ruwire_equalcstrsize_p(RuWire * self, char * str, size_t size) {
  int index = 0;
  if (!self) return 0;
  if (!self->data) return self->data == str;
  if (!str)  return 0;
  if (size != self->size) return 0;
  for(index = 0; index < size; index++) {
    if(self->data[index] != str[index]) return 0;
  }
  return !0;
}

int ruwire_equalcstr_p(RuWire * self, char * str) {
  return ruwire_equalcstrsize_p(self, str, si_strlen(str));
}



/*
static size_t re_strlen(char * str) {
  int res;   
  if(!str) return NULL;
  for(res = 0; (*str) != '\0' ; str++ ) { res++; }
  return res;  
};

static char * re_strdup(char * str) {
  char * res;
  int ind, len;
  if(!str) return NULL;
  len = re_strlen(str);
  res = re_malloc(len);
  for(ind = 0; ind < len; ind++) { res[ind] = str[ind]; } 
  return res;
}



RuWire * ruwire_init(RuWire * self, char * str, int size, int room) {
  if (room == 0) // constant string {
    self->data = str;
    self->size = re_strlen(str);
    self->room = room;  
  } else {
    self->data = re_strdup(str);
    self->size = re_strlen(str);
    self->room = room;
  }
};
*/








