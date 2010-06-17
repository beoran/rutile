#include "ruru.h"






int main(void) {
  RuRuntime * runtime;
  RU_STACKALLOC(pruntime, sizeof(RuRuntime));
  runtime = ru_runtime_default_get(NULL);
  //  (RuRuntime *) pruntime;
  void * block;
  ru_runtime_init(runtime, ru_alloc, ru_free);
  block = RU_DO1(runtime, alloc, 123);
  printf("%x %x\n", block, pruntime);
  RU_DO1(runtime, free, block);
}









