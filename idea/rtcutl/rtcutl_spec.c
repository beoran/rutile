#include "rtcutl.h"
#include "spec.h"


#define ASIZE 10

describe(Array)
  Array a; 
  int buf[ASIZE];
  
  it(can be initialized) {
    int i;
    i = 1;
    should(array_init(&a, buf, ASIZE, sizeof(int)) != NULL);
  } end

done




