#include <stdio.h>
#include "ruthing.h"
#include "ruwire.h"


int main(int argc, char * argv[]) {
  RuWire * str = ruwire_new("Hello");
  ruwire_adds(str, " world!");
  ruwire_puts(str);
  RUTHING_TOSS(str);
  return 0;
}


