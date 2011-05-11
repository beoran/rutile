require "parslet"

module Rutile

class Parser < Parslet::Parser
  def initialize
    super
  end

  root(:unit)
  rule(:constant_name) { match['A-Z'] >> (match['A-Z0-9_'].repeat)  }
  rule(:type_name)     { match['A-Z'] >> (match['a-z0-9_'].repeat)  }
  rule(:identifier)    { match['a-z'] >> (match['a-z0-9_'].repeat) >> match['!?'].any }
  rule(:instance_var)  { match['@']   >> (match['a-z0-9_'].repeat)  }
  rule(:ws)            { match['\s'].repeat                         }
  rule(:ows)           { match['\s'].any?                           }
  rule(:crlf)          { match['\r']  >> match['\n']                }
  rule(:cr)            { match['\r']                                }
  rule(:lf)            { match['\n']                                }
  rule(:eol)           { lf  | crlf | cr                            }
  rule(:define)        { str('def')                                 }
  rule(:method_def)    { define >> identifier >> argument_list      } 
  rule(:unit) do
    rule(:constant_name) 
  end
end

end # module Rutile










=begin
rutile: 
 
UNIT          -> UNIT_EXPR UNIT | . 
UNIT_EXPR     -> FUNC_DECL  | FUNC_DEF | CONST_DEF 
| REQUIRE_EXPR | PUBLIC_EXPR | PRIVATE_EXPR 
| STRUCT_EXPR | UNION_EXPR | EMPTY_LINE | comment . 
EMPTY_LINE      -> NL .
NL              -> eol | semicolumn .
REQUIRE_EXPR    -> require string NL .
PUBLIC_EXPR     -> public NL.
PRIVATE_EXP     -> private NL.
CONST_DEF       -> constname equal CONST_VAL NL.
CONST_VAL       -> constname | string | intval | floatval .
FUNC_RET        -> return ARGLIST .
FUNC_HEAD       -> FUNC_HEAD_NORET | FUNC_HEAD_RET . 
FUNC_HEAD_RET   -> FUNC_RET FUNC_NAME ARGLIST.
FUNC_HEAD_NORET -> FUNC_NAME ARGLIST.
FUNC_NAME     -> identifier .
FUNC_DECL     -> extern func FUNC_HEAD NL .
FUNC_DEF      -> func FUNC_HEAD NL FUNC_BODY end NL.
ARGLIST       -> oparen ARGBODY cparen.
ARGBODY       -> ARG ARGBODY |  .  
ARG           -> NAMEARG | NONAMEARG .
NAMEARG       -> identifier TYPE.
NONAMEARG     -> TYPE .
TYPE          -> typename TYPE_EXTRA .
TYPE_EXTRA    -> asterisk | .  
FUNC_BODY     -> FUNC_EXPR FUNC_BODY | .
FUNC_EXPR     -> REAL_EXPR.
JUNK_EXPR     -> blanks | comment .
REAL_EXPR     -> IDENT_EXPR | BLOCK | IF_EXPR | WHEN_EXPR | WHILE_EXPR | UNTIL_EXPR | constname | identifier.
IF_EXPR       -> if REAL_EXPR NL IF_BODY end NL.
IF_BODY       -> FUNC_BODY EEIF_EXPRS.
EEIF_EXPRS    -> ELIF_EXPRS ELSE_EXPR | .
ELIF_EXPRS    -> ELIF_EXPR ELIF_EXPRS | .
ELIF_EXPR     -> elif FUNC_BODY NL FUNC_BODY.
ELSE_EXPR     -> else FUNC_BODY.
WHILE_EXPR    -> while REAL_EXPR NL FUNC_BODY end NL.
UNTIL_EXPR    -> until REAL_EXPR NL FUNC_BODY end NL.
LOOP_EXPR     -> loop NL FUNC_BODY end NL.
RESCUE_EXPR   -> rescue REAL_EXPR NL FUNC_BODY end NL.
ENSURE_EXPR   -> ensure REAL_EXPR NL FUNC_BODY end NL.
CASE_EXPR     -> case REAL_EXPR NL CASE_BODY end NL.
CASE_BODY     -> WHEN_EXPR WHENELSE_EXPRS.
WHENELSE_EXPRS-> WHEN_EXPRS ELSE_EXPR | .
WHEN_EXPRS    -> WHEN_EXPR WHEN_EXPRS | .
WHEN_EXPR     -> when REAL_EXPR NL FUNC_BODY end NL.
RAISE_EXPR    -> raise REAL_EXPR NL.
OP_TAIL       -> OP REAL_EXPR.
OP            -> plus | minus | star | slash | percent | equals | dot.
VAR_DECL      -> identifier TYPE NL .
IDENT_EXPR    -> varname OP_TAIL | funcname PARAMLIST . 
PARAMLIST     -> oparen PARAMBODY cparen .
PARAMBODY     -> PARAM PARAMBODY | .
PARAM         -> REAL_EXPR .
BLOCK         -> obrace PARAMLIST NL FUNC_BODY cbrace NL
               | do PARAMLIST NL FUNC_BODY end NL .
STRUCT_EXPR   -> struct typename NL STRUCT_BODY end NL.
STRUCT_BODY   -> STRUCT_PART STRUCT_BODY | .
STRUCT_PART   -> VAR_DECL | CONST_DEF | FUNC_DEF | FUNC_DECL | ACCESS .
ACCESS        -> public | protected | private .
UNION_EXPR    -> union typename NL UNION_BODY end NL.
UNION_BODY    -> STRUCT_PART UNION_BODY | .
CLASS_EXPR    -> class typename NL CLASS_BODY end NL.
CLASS_BODY    -> STRUCT_PART CLASS_BODY | .
MODULE_EXPR   -> module typename NL CLASS_BODY end NL.


There is a bit of cheating here going on in that the parser will need 
a hash table to look up identifiers and see if the are unknow, defined as 
variables, or defined as functions, etc. 

func xy return Int Int (a Int b Int) 
end

=end


