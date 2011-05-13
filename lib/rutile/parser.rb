require "parslet"

module Rutile

class Parser < Parslet::Parser
  def initialize
    super
  end

  root(:unit)
  # whitespace handling: any low level token gobbles optional whitespace behind it.
  rule(:constant_name) do 
    (match['A-Z'] >> match['A-Z0-9_'].repeat).as(:constant_name)
  end
    
  rule(:type_name)     do 
    (match['A-Z'] >> match['a-z0-9_'].repeat(1)).as(:type_name)
  end  
  
  rule(:identifier)    do
    (match['a-z'] >> (match['a-z0-9_'].repeat) >>
     match['!?'].maybe).as(:identifier)
  end  
  
  rule(:member_name)   { match['@']   >> (match['a-z0-9_'].repeat)     }
  # Blanks and line endings
  rule(:blanknl)       { match[' \t\r\n']                              }
  rule(:blanknl?)      { blank.maybe                                   }
   
  rule(:blank)         { match[' \t']                                  }
  rule(:blank?)        { blank.maybe                                   }
  rule(:blanks)        { match[' \t'].repeat  || comment                    }
  rule(:blanks?)       { blanks.maybe                                       }
  rule(:ws)            { blanks       >> esceol.maybe >> blanks             }
  rule(:ws?)           { blanks.maybe >> esceol.maybe >> blanks.maybe       }
  rule(:crlf)          { match['\r']  >> match['\n']                        }
  rule(:cr)            { match['\r']                                        }
  rule(:lf)            { match['\n']                                        }
  rule(:cr_or_lf)      { lf  | crlf | cr                                    }
  # Comments
  rule(:line_comment)  do 
    str('#') >> (cr_or_lf.absent? >> any).repeat.as(:comment) >> cr_or_lf
  end
    
  rule(:block_comment)  do 
    str('#{') >> (str('}#').absent? >> any).repeat.as(:comment)
  end
  
  rule(:block_comment_2)  do 
    str('=begin') >> (str('=end').absent? >> any).repeat.as(:comment)
  end
  
  rule(:comment)       { line_comment | block_comment | block_comment_2     }
   
  # \\ can escape a line ending and turn it into whitespace.
  rule(:esceol)        { str('\\') >> blanks.maybe  >> cr_or_lf             }
  rule(:line_end)      { (str(';')| lf  | crlf | cr) >> ws?                 }
  rule(:line_end?)     { line_end.maybe                                     }
  rule(:eol)           { esceol.absent? >> line_end                         }
  rule(:ows_eol)       { ws? >> eol                                         } 
  rule(:define)        { str('def')                                         }
  rule(:method_def)    { define >> identifier >> argument_list              }
  rule(:eat_line_end)  { ws? >> line_end? >> ws?                            }
  rule(:empty_line)    { ws? >> line_end >> ws?                             }
  
  # commas eat line_end 
  rule(:comma)         { ws? >> str(',') >> eat_line_end                    }
  
  # assign eats line end
  rule(:assign)        { ws? >> str('=') >> eat_line_end                    }
  
  # open paren eats line end
  rule(:oparen)        { ws? >> str('(') >> eat_line_end                    }
  # close paren does not eat line end, but only whitespace!
  rule(:cparen)        { ws? >> str(')') >> ws?                             }
  # open bracket eats line end
  rule(:obracket)      { ws? >> str('[') >> eat_line_end                    }
  # close bracket does not eat line end, but only whitespace!
  rule(:cbracket)      { ws? >> str(']') >> ws?                             }
  # dot  eats line end
  rule(:dot)           { ws? >> str('.') >> ws?                             }

  
  rule(:colon)         { str(':') >> eat_line_end                           }
  
  # this is subtle: use this to state that a rule must be followed
  # only by anything that rule can parse, however, the tokens parsed by 
  # rule are not consumed
  def followed_by(rule)
    (rule.absent? >> any).absent?
  end
  
  def self.keywords(*names)
    names.each do |name|
      rule("kw_#{name}") do 
       # this is subtle: a keyword may be followed by blanks alone
       # so we say, not followe by(not blank followed by any character)
       # which means "followed by a blank character"
        str(name.to_s).as(name) >> followed_by(blanknl)
      end  
    end
  end

  keywords :def, :end, :extern, :struct, :union, 
           :if, :when, :case, :else, :elsif, :loop, :while, :until, 
           :require, :public, :private, :typedef, :return, :sizeof
  
  rule :end_bug do 
    kw_end | identifier
    # identifier | kw_end  would work, bu then keywords are not reserved 
  end
  
  # binary operators eat whitespace and newlines after them  
  def binop(name) 
    return ws? >> str(name.to_s).as(name.to_sym) >> eat_line_end
  end
  
  
  rule :float do
    (match('[0-9]').repeat(1) >> 
    str('.') >> 
    match('[0-9]').repeat(1) >>
    ( match['eE'] >> match['+-'].maybe >> 
    match('[0-9]').repeat(1)  ).maybe).as(:float)  # exponent
  end
  
  
  rule :integer do
    match('[0-9]').repeat(1).as(:integer)
  end
  
  rule :string do
    str('"') >>
    (
      (str('\\') >> any) |
      (str('"').absent? >> any)
    ).repeat.as(:string) >>
    str('"')
  end
  
  rule :literal do
    (float | integer | string).as(:literal) >> ws?
  end
  
  rule :empty_lines do
    empty_line.repeat
  end
  
  rule(:require_action) { ws? >> kw_require >> ws >> string >> ows_eol   }
  rule(:public_action)  { ws? >> kw_public >> ows_eol                    }
  rule(:private_action) { ws? >> kw_private >> ows_eol                   }
  
  rule :compiler_action do
    require_action  | private_action    | public_action  
  end
  
  rule :unit_part do
      compiler_action | 
      constant_set    | variable_set      | extern_function | 
      define_function | extern_struct     | define_struct   |
      extern_union    | define_union      | typedef         | 
      extern_typedef  | comment           | empty_line
  end
  
  rule :unit do
    unit_part.repeat
  end
  
  # types and type declarations : 
  rule(:pointersign)    { str('@').repeat.as(:pointer)                      }
  rule(:pointersign?)   { pointersign.maybe                                 }
  rule(:type)           { (type_name >> pointersign?).as(:type)             }
  rule(:type_declare)   { (type  >> ws).as(:type_declare)                   }
  rule(:type_declare?)  { type_declare.maybe                                }


  def optional_type(rule)
    return (type_declare >> rule).as(:type_declare_of) | rule
  end

  rule(:constant_set)   do
    ws? >> optional_type(constant_name) >> assign >> literal >> eol 
  end
  
  
  rule(:variable_set)   do
    (ws? >> optional_type(identifier) >>  assign >> 
    literal >> eol).as(:variable_set) 
  end

  
  rule(:argument)        do 
    (variable_set | optional_type(identifier) |
    str('...')).as(:argument)
  end
  
  rule(:argument_list_noparen) do 
    argument >> ( comma >> argument ).repeat.maybe
  end
  
  rule(:argument_list_paren) do 
    oparen >> argument_list_noparen >> cparen 
  end
  
  rule(:argument_list )  do 
    (argument_list_paren | argument_list_noparen).as(:argument_list)
  end
  
  rule(:argument_list?) do 
    argument_list.maybe
  end
  

  
  rule(:function_head)  do 
    (optional_type(identifier) >> ws? >> argument_list?).as(:function_head)   
  end
  
  rule(:extern_function) do
    (ws? >> kw_extern >> ws >> kw_def  >> ws >>
    function_head >> ows_eol).as(:extern_function) 
  end
  
  rule(:define_function) do  
    (kw_def >> ws >> function_head >> ows_eol >>
     function_body >> kw_end >> ows_eol).as(:define_function)
     
  end
  
  rule(:function_body) do
    (function_statement.repeat.maybe).as(:function_body) 
  end 
  
=begin 
A.2.3 Statements
(6.8) statement:
labeled-statement
compound-statement
expression-statement
selection-statement
iteration-statement
jump-statement

(6.8.1) labeled-statement:
identifier : statement
case constant-expression : statement
default : statement
(6.8.2) compound-statement:
{ block-item-list? }
(6.8.2) block-item-list:
block-item
block-item-list block-item
(6.8.2) block-item:
declaration
statement
(6.8.3) expression-statement:
expression? ;
(6.8.4) selection-statement:
if ( expression ) statement
if ( expression ) statement else statement
switch ( expression ) statement

(6.8.5) iteration-statement:
while ( expression ) statement
do statement while ( expression ) ;
for ( expressionopt ; expressionopt ; expressionopt ) statement
for ( declaration expressionopt ; expressionopt ) statement

(6.8.6) jump-statement:
goto identifier ;
continue ;
break ;
return expressionopt ;


=end
  
  rule(:function_statement) do
    constant_set   | variable_set         | # loop_statement |
    empty_line
    # case_statement | while_statement      |
    # until_statement | # | expression_statement | 
    # if_statement    | 
    
  end
  
  rule(:condition) do 
    expression.as(:condition) 
  end  
  
  rule(:expression_statement) do
    ws? >> expression >> eol
  end  
  
  
  rule(:if_statement) do
    (ws? >> kw_if >> condition >> eol >> 
    if_body >> kw_end >> eol).as(:if_statement)
  end 
    
  rule(:if_body) do 
    function_body >> elseif_statements.maybe
  end
 
  rule(:elseif_statements) do 
    elsif_statement.repeat.maybe >> else_statement
  end
  
  rule(:elsif_statement) do 
    (ws? >> kw_elsif >> condition >> eol >> 
    if_body >> kw_end >> eol).as(:elsif_statement)
  end
  
  rule(:else_statement) do 
    (ws? >> kw_else >> eol >> 
    if_body >> kw_end >> eol).as(:else_statement)
  end
  
  rule(:while_statement) do
    (ws? >>  kw_while >> condition >> eol >> 
    loop_body >> kw_end >> eol).as(:while_statement)
  end
  
  rule(:until_statement) do
    (ws? >>  kw_until >> condition >> eol >> 
    loop_body >> kw_end >> eol).as(:until_statement)
  end
  
  rule(:loop_statement) do
    (ws? >>  kw_loop >> kw_do >> eol >> 
    loop_body >> kw_end >> eol).as(:loop_statement)
  end
  
  rule(:break_statement) do
    (ws? >> kw_break >> eol).as(:break_statement)
  end
  
  rule(:next_statement) do
    (ws? >> kw_next  >> eol).as(:next_statement)
  end 
  
  rule(:loop_statement) do 
    function_statement | break_statement | next_statement
  end  
  
  rule(:loop_body) do
    (loop_statement.repeat.maybe).as(:loop_body)  
  end
  
  rule(:case_statement) do 
    (ws? >>  kw_case >> condition >> eol >> 
    case_body >> kw_end >> eol).as(:case_statement)
  end
    
  rule(:case_body) do 
    when_statement.repeat.maybe >> else_statement
  end  
  
  rule(:when_statement) do 
    (ws? >>  kw_when >> condition >> eol >>
    function_body >> kw_when.absent?).as(:when_statement)
  end
  
  # Expression tower starts here 
  rule(:primary_expression) do
    identifier | # constant_expression | 
    literal | oparen >> expression >> cparen
  end
  
  # Function calls and method calls parameters 
  rule(:parameter) do
    (expression | str('...')).as(:parameter)
  end
  
  rule(:parameter_list_1) do 
    parameter >> ( comma parameter ).repeat.maybe
  end
  
  rule(:parameter_list_2) do 
    oparen >> parameter_list_1 >> cparen
  end  
  
  rule(:parameter_list)  do 
    (parameter_list_2 | parameter_list_1).as(:parameter_list)  
  end
  
  rule(:parameter_list?)  do 
    parameter_list.maybe
  end

  rule(:function_call) do
     (postfix_expression >> parameter_list?).as(:function_call)
  end
  
  rule(:array_index) do
     (postfix_expression >> obracket >> expression >> cbracket).as(:array_index) 
  end
  
  rule(:member_select) do
     (postfix_expression >> dot >> identifier).as(:member_select)
  end
  
  rule(:send_message) do
     (postfix_expression >> dot >> identifier >> parameter_list).as(:send_message)
  end
  
  rule(:post_decrement) do
     (postfix_expression >> ws? >> str('--') >> ws?).as(:post_decrement)
  end
  
  rule(:post_increment) do
     (postfix_expression >> ws? >> str('++') >> ws?).as(:post_decrement)
  end
  
  rule(:pre_decrement) do
     (kw('--') >> unary_expression).as(:pre_decrement)
  end
  
  rule(:pre_increment) do
     (kw('++') >> unary_expression).as(:pre_decrement)
  end
  
  
  rule(:postfix_expression) do 
    primary_expression | 
    array_index        | 
    function_call      | 
    send_message       |
    member_select      |
    post_decrement     |
    post_increment
  end
  
  rule(:sizeof_expression) do
    (kw_sizeof >> oparen >> unary_expression >> cparen).as(:sizeof_expression)
  end
  
  rule(:sizeof_type) do
    (kw_sizeof >> oparen >> type_name >> cparen).as(:sizeof_type)
  end
  
  
  rule(:unary_expression) do 
    postfix_expression                                               |
    (unary_operator >> ws? >> cast_expression).as(:unary_operation)  |
    sizeof_expression                                                |
    sizeof_type
  end 
   
  rule(:unary_operator) do 
    match['&+-~'].as(:unary_operator) # removed * 
  end
  
  rule(:cast_expression) do 
    unary_expression |
    oparen >> type_name >> cparen >> cast_expression
  end
  
  def binex(first, ope, second, name)
    opaid = binop(ope)
    return (first >> ws? >> str(ope).as(:ope) >> ws? >> second).as(name)
  end
  
  rule(:multiplicative_expression) do 
    cast_expression | 
    binex(multiplicative_expression, '*', cast_expression, :multiply) |
    binex(multiplicative_expression, '/', cast_expression, :divide)   |
    binex(multiplicative_expression, '%', cast_expression, :modulus)
  end
  
  rule(:additive_expression) do 
    multiplicative_expression |
    binex(additive_expression, '+',  multiplicative_expression, :add) | 
    binex(additive_expression, '-',  multiplicative_expression, :substract)
  end
  
  rule(:shift_expression) do 
    additive_expression |
    binex(shift_expression, '>>',  additive_expression, :leftshift) | 
    binex(shift_expression, '<<',  additive_expression, :rightshift)
  end
  
  rule(:relational_expression) do
    additive_expression | 
    binex(relational_expression, '<',  shift_expression, :lessthan) |
    binex(relational_expression, '>',  shift_expression, :morethan) |
    binex(relational_expression, '<=',  shift_expression, :lessorequal) |
    binex(relational_expression, '>=',  shift_expression, :moreorequal) 
  end 
   
  rule(:equality_expression) do 
    relational_expression | 
    binex(equality_expression, '==', relational_expression, :equal)   |
    binex(equality_expression, '!=', relational_expression, :inequal) 
  end
    
  rule(:binand_expression) do
    equality_expression | 
    binex(binand_expression, '&', equality_expression, :binaryand)  
  end  
  
  rule(:binxor_expression) do
    binand_expression | 
    binex(binxor_expression, '^', binand_expression, :binaryxor)  
  end  
  
  rule(:binor_expression) do
    binxor_expression | 
    binex(binor_expression, '|', binxor_expression, :binaryor)  
  end  
  
  rule(:logicand_expression) do
    binor_expression | 
    binex(logicand_expression, '&&', binor_expression, :logicand)  
  end  
   
  rule(:logicor_expression) do
    logicand_expression | 
    binex(logicor_expression, '||', logicand_expression, :logicor)  
  end  
  
  rule(:conditional_expression) do
    logicor_expression | 
    (logicor_expression >> binop('?') >> expression >> 
    binop(':') >> conditional_expression).as(:ternary_operator)
  end
  
  rule(:assignment_expression) do 
    conditional_expression | 
    (unary_expression assignment_operator assignment_expression).as(:assign)
  end
    
  rule(:assignment_operator) do
    op('=')   || op('*=')  || op('/=') || op('%=') || op('+=') || op('-=') ||
    op('<<=') || op('>>=') || op('&=') || op('^=') || op('|=') 
  end 
  
  rule(:expression) do
    assignment_expression 
  end 
  
  rule(:constant_expression) do
    conditional_expression
  end
  
  rule(:define_struct) do 
    (ws? >> kw_struct >> type_name.as(:name) >>  eol  >> 
    struct_body >> kw_end).as(:define_struct)
  end
     
  rule(:define_union) do 
    (ws? >> kw_struct >> type_name.as(:name) >>  eol >> 
    union_body >> kw_end).as(:define_struct)
  end
  
  rule(:define_member) do
    (ws? >> optional_type(member_name) >> 
    (assign >> expression).maybe >> ws? >> eol).as(:define_member) 
  end
  
  rule(:union_part) do
    define_member   | private_action  | public_action   | 
    extern_struct   | define_struct   | 
    constant_set    | variable_set    | extern_function | 
    define_function | comment         | empty_line
  end
  
  rule(:union_body) do
    (union_part.repeat.maybe).as(:body)
  end
  
  rule(:struct_part) do
    define_member   | private_action    | public_action   |
    extern_union    | define_union      |
    constant_set    | variable_set      | extern_function |
    define_function | comment           | empty_line 
  end
  
  rule(:struct_body) do
    (struct_part.repeat.maybe).as(:body)
  end
  

  rule(:extern_struct) do
    (ws? >> kw_extern >> kw_struct >> type_name >>  eol).as(:extern_struct) 
  end
  
  rule(:extern_union) do
    (ws? >> kw_extern >> kw_union >> type_name >>  eol).as(:extern_union) 
  end
  
  rule(:typedef) do
    (ws? >> kw_typedef >> type >> type_name >>  eol).as(:typedef)
  end
  
  rule(:extern_typedef) do 
    (ws? >> kw_extern >> kw_typedef >> type_name >>  eol).as(:extern_typedef)
  end
 
  

  
end # class Parser

end # module Rutile

=begin
Ruby operators: 


Y   [ ] [ ]=  Element reference, element set
Y   **  Exponentiation
Y   ! ~ + -   Not, complement, unary plus and minus (method names for the last two are +@ and -@)
Y   * / %   Multiply, divide, and modulo
Y   + -   Plus and minus
Y   >> <<   Right and left shift
Y   &   Bitwise `and'
Y   ^ |   Bitwise exclusive `or' and regular `or'
Y   <= < > >=   Comparison operators
Y   <=> == === != =~ !~   Equality and pattern match operators (!= and !~ may not be defined as methods)
  &&  Logical `and'
  ||  Logical `or'
  .. ...  Range (inclusive and exclusive)
  ? :   Ternary if-then-else
  = %= { /= -= += |= &= >>= <<= *= &&= ||= **=  Assignment
  defined?  Check if symbol defined
  not   Logical negation
  or and  Logical composition
  if unless while until   Expression modifiers
  begin/end   Block expression
  
=end








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
FUNC_HEAD       -> FUNC_HEAD_NORET | FUNC_HEAD_RET. 
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


