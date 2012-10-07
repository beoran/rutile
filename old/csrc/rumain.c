#include <stdio.h>
#include "ruthing.h"
#include "ruwire.h"


void * test_thing_done(void * ptr) {
  printf("I'm all done with you, %p, your box is: %p!\n",
          ptr, RU_BOX_OF(ptr));
  return NULL;
}

int main(int argc, char * argv[]) {
  RuWire * str = ruwire_new("Hello");
  RuBox  * box = rubox_newalloc(64, &test_thing_done);
  char * try   = (char *) box->ptr;
  try[63]      = '!';
  ruwire_adds(str, " world!");
  ruwire_puts(str);
  RUTHING_TOSS(str);
  printf("sizeof RuThing: %d, RuValue *: %d, RuString: %d\n",
          sizeof(RuThing), sizeof(RuValue), sizeof(RuWire));
  printf("box: %p %p %d\n", box, box->ptr, sizeof(RuBox));
  RUTHING_TOSS(box);
  return 0;
}







