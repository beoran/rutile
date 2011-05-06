require 'test_helper'
require 'rutile'

assert { Rutile } 

assert { Rutile::Lexer }
lex = nil
assert { lex = Rutile::Lexer.new('hello') }
include Rutile


def lexer_ok(lexer, kind = nil, value = nil, line = nil, col = nil)
  token = lexer.lex
  if kind && kind != token.kind
    warn "Kind not correct!: #{token.inspect}"
    return false
  end
  
  if value && value != token.text
    warn "Value not correct!: #{token.inspect}"
    return false
  end
  if line && line != token.line
    warn "Line not correct!: #{token.inspect}"
    return false
  end   
  
  if col && col != token.coln 
    warn "Column not correct!: #{token.inspect}"
    return false
  end   
  return true 
end

def lex_ok(input, kind = nil, value = nil, line = nil, col = nil)
  lexer = Rutile::Lexer.new(input)
  return lexer_ok(lexer, kind = nil, value = nil, line = nil, col = nil)
end  


assert { lex_ok('++', :operator, '++', 1, 2) }
lex = Lexer.new("++\n++")
assert { lexer_ok(lex, :operator, '++', 1, 2) }
assert { lexer_ok(lex, :endline , "\n", 1, 3) }
assert { lexer_ok(lex, :operator, '++', 2, 1) }





