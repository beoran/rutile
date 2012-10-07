#include "ruthing.h"
#include "rulex.h"


RuToken * rutoken_done(void * ptr) {
  // the pointer we gets points to the contents of the wrapping box, not to
  // a token, hence, we need RU_BOX_OF(PTR)
  RuToken * self = (RuToken *) RU_BOX_OF(ptr);
  //  ((char *) ptr) - offsetof(RuBox, ptr);
  // RU_BOX_OF(ptr, RuToken); 
  return NULL;
} 



