#include <stdlib.h>
#include <stdint.h>


#include "ruthing.h"
#include "ruwire.h"


RuThing * ruthing_init(RuThing * self, uint8_t type, uint8_t flag) {
  if (!self) return NULL;
  self->refc = 1;
  self->type = type;
  self->flag = flag;
  return self;
}

#define RUTHING_MAXREF 32000


RuThing * ruthing_use(RuThing * self) {
  if(!self) return self;
  if(self->refc > RUTHING_MAXREF) return self;
  self->refc++;
  return self;
}


RuWire * ruwire_done(RuWire * wire);


RuThingFreeFunc *ruthing_free_functions[RU_THINGTYPE_BUILTIN] = {
  NULL,         // RU_THINGTYPE_FAIL
  NULL,         // RU_THINGTYPE_OK 
  NULL,         // RU_THINGTYPE_INT 
  NULL,         // RU_THINGTYPE_NUMBER  =  3,
  ruwire_done,  // RU_THINGTYPE_WIRE  =  4,
  NULL,         // RU_THINGTYPE_BUFFER  =  5,
  NULL,         // RU_THINGTYPE_ARRAY   =  6,
  NULL,         // RU_THINGTYPE_TAB     =  7,
  NULL,         // RU_THINGTYPE_DEF     =  8,
  NULL,         // RU_THINGTYPE_CODE    =  9,
  NULL,         // RU_THINGTYPE_BOX     = 10,
  NULL,         //RU_THINGTYPE_BRIDGE   = 11,  
};


RuThing * ruthing_free(RuThing * self) {
  RuThingFreeFunc * func = NULL;
  if(!self) return NULL; 
  func = ruthing_free_functions[self->type];
  if(func) {
    func(self);
  }
  if(!(self->flag & RU_THINGFLAG_STATIC)) {
    free(self);
    return NULL;
  }
  return self;
}


RuThing * ruthing_toss(RuThing * self) {
  if(!self) return self;
  // more than maxref means it's an "immortal" or "immortalized" object.
  if(self->refc > RUTHING_MAXREF) return self;
  // already 0 refs, leave it at that.
  if(self->refc == 0)             return self;
  self->refc--;
  if(self->refc == 0) {
    ruthing_free(self);
  }
  return self;
}



