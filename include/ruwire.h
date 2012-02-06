#ifndef RUWIRE_H
#define RUWIRE_H

#include <stdint.h>
#include "ruthing.h"


struct RuWire_ {
  RuThing parent;
  char  * data;
  int     size;
  int     room;
};

typedef struct RuWire_ RuWire;

/** Allocates a new Rutile Wire, and copies str into it.  */
RuWire * ruwire_new(char * s);

/** Ensures null termination of the wire. self->size should be correct. */
RuWire * ruwire_null_terminate(RuWire * self);

/** Initializes a wire from a constant string with a given length.
It is the caller's responsality to ensure size is correct and that str
is properly \0 terminated. */
RuWire * ruwire_init_const_size(RuWire * self, const char * str, size_t size);

/** Initializes a wire from a constant string. */
RuWire * ruwire_init_const(RuWire * self, const char * str);

/** Calls puts on the wire. */
int ruwire_puts(RuWire * self);

/** Allocates a RuWire struct. */
RuWire * ruwire_alloc();

/** Frees a RuWire struct, calling ruwire_done if needed. Returns NULL. */
RuWire * ruwire_free(RuWire * self);

/** Changes the room available in the RuWire. */
RuWire * ruwire_room_(RuWire * self, size_t room);

/** Grows the RuWire if needed. */
RuWire * ruwire_room_grow(RuWire * self, size_t newroom);

/** Concatenates char to self, growing self if needed. */
RuWire * ruwire_addc(RuWire * self, char c);

/** Concatenates str to self, growing self if needed. */
RuWire * ruwire_addcstr_size(RuWire * self, char * str, size_t size);

/** Concatenates str to self, growing self if needed. */
RuWire * ruwire_adds(RuWire * self, char * str);

/** Concatenates wire to self, growing self if needed. */
RuWire * ruwire_add(RuWire * self, RuWire * wire);

/** Duplicates a wire. Must be freed with si_wire_free.
Const wires will become non-const.
*/
RuWire * ruwire_dup(RuWire * self);

/** Creates a new empty wire */
RuWire * ruwire_empty();

/** Checks if a rewire is empty */
int ruwire_empty_p(RuWire *self);

/** Concatenates two Wires. The result is a newly allocated RuWire,
that should be freed. */
RuWire * ruwire_cat(RuWire * w1, RuWire * w2);

/** Gets a substring of the Wire. The result is a newly allocated RuWire. */
RuWire * ruwire_mid(RuWire * self, size_t start, size_t amount);

/** Gets a left substring of the Wire. The result is a newly allocated RuWire. */
RuWire * ruwire_left(RuWire * self, size_t amount);

/** Gets a right substring of the Wire. The result is a newly allocated RuWire. */
RuWire * ruwire_right(RuWire * self, size_t amount);

/** Checks if the given index is valid for the wire. */
int ruwire_index_ok(RuWire * self, size_t index);

/** Gets a character at index index from the wire.
Returns 0 if index if not valid. */
char ruwire_index(RuWire * self, size_t index);

/** Sets a character at index index from the wire.
Returns NULL if index if not valid. Otherwise returns self. */
RuWire * ruwire_index_(RuWire * self, size_t index, char c);

/** Joins a variable amount of wires together with join in between them.
* Result is newly allocated and must be freed.
*/
RuWire * ruwire_join_va(RuWire * join, size_t amount, ...);

/** Joins a variable amount of wires together with join in between them.
* Result is newly allocated and must be freed.
*/
RuWire * ruwire_join_ar(RuWire * join, size_t amount, RuWire ** ar);

/** Compares two wires for equality in size and contents. */
int ruwire_equal_p(RuWire * self, RuWire * wire);

/** Compares a wire and a c string for equality in size and contents. */
int ruwire_equalcstrsize_p(RuWire * self, char * str, size_t size);



#endif


