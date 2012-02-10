#ifndef RUTHING_H
#define RUTHING_H

#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>


enum RuThingType_ {
  RU_THINGTYPE_FAIL    =  0,
  RU_THINGTYPE_OK      =  1,
  RU_THINGTYPE_INT     =  2,
  RU_THINGTYPE_NUMBER  =  3,
  RU_THINGTYPE_WIRE    =  4,
  RU_THINGTYPE_BUFFER  =  5,
  RU_THINGTYPE_ARRAY   =  6,
  RU_THINGTYPE_TAB     =  7,
  RU_THINGTYPE_DEF     =  8,
  RU_THINGTYPE_CODE    =  9,
  RU_THINGTYPE_BOX     = 10,
  RU_THINGTYPE_BRIDGE  = 11,
  RU_THINGTYPE_BUILTIN = 12,
};

typedef enum RuThingType_ RuThingType;

enum RuThingFlag_ {
  RU_THINGFLAG_NONE   = 0,
  RU_THINGFLAG_STATIC = 1,
};

typedef enum RuThingFlag_ RuThingFlag;

struct RuThing_ {
  uint16_t refc;
  uint8_t  type;
  uint8_t  flag;
};

typedef struct RuThing_ RuThing;

typedef void * (RuDoneFunc)(void * ptr);

struct RuBox_ {
  RuThing      parent;  
  void       * ptr;
  int          size;
  RuDoneFunc * done;
};

typedef struct RuBox_ RuBox;


typedef RuThing * (RuThingFunc)(RuThing * thing, ...);

union RuValue_ {
  float         fl;
  int           in;
  void        * pt;
  RuThingFunc * fn;
};

typedef union RuValue_ RuValue;

typedef RuThing * (RuThingFreeFunc)(RuThing * thing);


RuThing * ruthing_init(RuThing * self, uint8_t type, uint8_t flag);
RuThing * ruthing_use(RuThing * self);
RuThing * ruthing_free(RuThing * self);
RuThing * ruthing_toss(RuThing * self);

#define RUTHING_INIT(THINGP, TYPE, FLAG)  \
        (ruthing_init((RuThing*)(THINGP), (TYPE), (FLAG)))
#define RUTHING_TOSS(THINGP)  (ruthing_toss((RuThing*)(THINGP)))
#define RUTHING_USE(THINGP)   (ruthing_use((RuThing*)(THINGP)))

/** Allocates new space and wraps it in a RuBox. Done is a cleanup function. */
RuBox * rubox_newalloc(int size, RuDoneFunc * done);

/** IF rubox_newalloc was used, this macro returns the wrapping RuBox
pointer based on the box's ->ptr;  */
#define RU_BOX_OF(PTR) (((char *)(PTR)) - sizeof(RuBox))


#endif
