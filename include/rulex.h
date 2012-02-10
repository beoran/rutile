#ifndef RULEX_H
#define RULEX_H

#include "ruthing.h"
#include "ruwire.h"

enum RuTokenKind_ {
  // values less than 255 are used for character constant tokens, like +, =, etc.
  // and let's start around 300 for future extensibility and beauty of the
  // numbers used.

  RU_TOKENKIND_AS         = 300,
  RU_TOKENKIND_BREAK      = 301,
  RU_TOKENKIND_CASE       = 302,
  RU_TOKENKIND_CLASS      = 303,
  RU_TOKENKIND_COMETO     = 304,
  RU_TOKENKIND_CONST      = 305,
  RU_TOKENKIND_CONTINUE   = 306,  
  RU_TOKENKIND_DO         = 307,
  RU_TOKENKIND_ELSE       = 308,
  RU_TOKENKIND_END        = 309,  
  RU_TOKENKIND_ENUM       = 310,
  RU_TOKENKIND_EXTERN     = 311,
  RU_TOKENKIND_FAIL       = 312,
  RU_TOKENKIND_FALLTHROUGH= 313,
  RU_TOKENKIND_FUN        = 314,
  RU_TOKENKIND_FOR        = 315,
  RU_TOKENKIND_FOREACH    = 316,
  RU_TOKENKIND_GOTO       = 317,  
  RU_TOKENKIND_IF         = 318,
  RU_TOKENKIND_IMMUTABLE  = 319,
  RU_TOKENKIND_INTERFACE  = 320,  
  RU_TOKENKIND_LET        = 321,
  RU_TOKENKIND_LOOP       = 322,
  RU_TOKENKIND_MODULE     = 323,
  RU_TOKENKIND_PUBLIC     = 324,
  RU_TOKENKIND_PRIVATE    = 325,
  RU_TOKENKIND_REPEAT     = 326,
  RU_TOKENKIND_RETURN     = 327,
  RU_TOKENKIND_REQUIRE    = 328,  
  RU_TOKENKIND_SELF       = 329,  
  RU_TOKENKIND_SUCCESS    = 330,
  RU_TOKENKIND_STATIC     = 331,
  RU_TOKENKIND_STRUCT     = 332,
  RU_TOKENKIND_THEN       = 333,
  RU_TOKENKIND_TYPEDEF    = 334,
  RU_TOKENKIND_UNION      = 335,
  RU_TOKENKIND_UNSAFE     = 336,
  RU_TOKENKIND_UNTIL      = 337,
  RU_TOKENKIND_WHILE      = 338,
  RU_TOKENKIND_WEND       = 339,
  /* Literal constants, start with 400. */
  RU_TOKENKIND_STRING     = 400,
  RU_TOKENKIND_CHAR       = 401,
  RU_TOKENKIND_FLOAT      = 402,
  RU_TOKENKIND_INTEGER    = 403,
  /* General tokens, start with 500 */
  RU_TOKENKIND_IDENTIFIER = 500,
  RU_TOKENKIND_TYPENAME   = 501,
  RU_TOKENKIND_CONSTANT   = 502,  
  RU_TOKENKIND_MACROMETA  = 503,
  // Line end are newlines that are not preceded by certain exceptions
  // like a comma (,) , and also semicolons (;)
  RU_TOKENKIND_LINE_END   = 504,
  // Comments and other ignorables. 
  RU_TOKENKIND_COMMENT    = 600,  
}; 


typedef enum RuTokenKind_ RuTokenKind;

struct RuToken_;
typedef struct RuToken_ RuToken;

struct RuToken_  {
  RuBox     parent;
  RuWire    text;
  RuToken * after;
  RuToken * before;
};











#endif
