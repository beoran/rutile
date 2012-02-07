#include <stdio.h>
#include "ruthing.h"
#include "ruwire.h"


int main(int argc, char * argv[]) {
  RuWire * str = ruwire_new("Hello");
  ruwire_adds(str, " world!");
  ruwire_puts(str);
  RUTHING_TOSS(str);
  printf("sizeof RuThing: %d, RuValue *: %d, RuString: %d\n",
          sizeof(RuThing), sizeof(RuValue), sizeof(RuWire));
  return 0;
}







