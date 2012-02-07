#ifndef RULEX_H
#define RULEX_H

#include "ruthing.h"
#include "ruwire.h"

enum RuTokenKind_ {
  // values less than 255 are used for character constant tokens, like +, =, etc.
  RU_TOKENKIND_KEYWORD    = 256,
  RU_TOKENKIND_IDENTIFIER = 257,
  RU_TOKENKIND_TYPENAME   = 258,
  RU_TOKENKIND_MACRO  = 259,
  
}; 




struct RuToken_  {
  RuThing thing;
  
  RuString text;
  
};  


RuLexer 







#endif
