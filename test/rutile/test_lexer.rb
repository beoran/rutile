require 'test_helper'
require 'rutile'

assert { Rutile } 

assert { Rutile::Lexer }
lex = nil
assert { lex = Rutile::Lexer.new('hello') }
include Rutile


def lexer_ok(lexer, kind = nil, value = nil, line = nil, col = nil)
  token = lexer.lex_skip(:space)
  if kind && kind != token.kind
    warn "Kind not correct!: #{token.inspect}"
    return false
  end
  
  if value && value != token.value
    warn "Value not correct!: #{token.inspect}"
    return false
  end
  if line && line != token.line
    warn "Line not correct!: #{token.inspect}"
    return false
  end   
  
  if col && col != token.column
    warn "Column not correct!: #{token.inspect}"
    return false
  end   
  return true 
end

def lex_ok(input, kind = nil, value = nil, line = nil, col = nil)
  lexer = Rutile::Lexer.new(input)
  return lexer_ok(lexer, kind = nil, value = nil, line = nil, col = nil)
end  

assert { lex_ok('++', :operator, '++' , 1, 2) }
str = %q{++  
+++2.3 44 CONST_1 Type_1 $global_1 iDENtifier_!?
'String with \\' an escape'
"String with \\' an escape"
0x1f
0b010
0o71
0b765
0b
<=>
#{ this is comment 
}
#this too
}
lex = Lexer.new(str)
assert { lexer_ok(lex, :operator, '++'  , 1, 2) }
# assert { lexer_ok(lex, :space   , nil   , 1, 4) }
assert { lexer_ok(lex, :endline , "\n"  , 1, 4) }
assert { lexer_ok(lex, :operator, '+++' , 2, 3) }
assert { lexer_ok(lex, :float   , 2.3   , 2, 6) }
# assert { lexer_ok(lex, :space   , nil   , 2, 7) }
assert { lexer_ok(lex, :integer , 44    , 2, 9) }
# assert { lexer_ok(lex, :space   , ' '   , 2, 10) }
assert { lexer_ok(lex, :constant, 'CONST_1') }
# assert { lexer_ok(lex, :space) }
assert { lexer_ok(lex, :typename, 'Type_1') }
# assert { lexer_ok(lex, :space) }
assert { lexer_ok(lex, :global, '$global_1') }
# assert { lexer_ok(lex, :space) }
assert { lexer_ok(lex, :identifier, 'iDENtifier_!?') }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :string, %q{'String with \\' an escape'}) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :string, %q{"String with \\' an escape"}, 4) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :integer , 0x1f) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :integer , 0b010) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :integer , 071) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :error) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :error) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :operator) }
assert { lexer_ok(lex, :endline) }
assert { lexer_ok(lex, :comment) }
assert { lexer_ok(lex, :comment) }
assert { lexer_ok(lex, :eof) }
assert { lexer_ok(lex, :eof) }



