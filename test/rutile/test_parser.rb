require 'test_helper'

require 'rutile'

assert { Rutile::Parser }
 
assert { Rutile::Parser.new }

def parse(rule, text)
  parser = Rutile::Parser.new
  rule   = parser.send(rule.to_sym)
  return rule.parse(text)
  rescue $! 
  p $!
  return nil 
end

def noparse(rule, text)
  parser = Rutile::Parser.new
  rule   = parser.send(rule.to_sym)
  rule.parse(text)
  return false
  rescue $! 
  # p $!
  return true 
end


  
assert { parse :constant_name, 'HELLO'    }
assert { noparse :constant_name, 'HeLLO'  }
assert { parse :eol, "\n"                 }
assert { parse :eol, "\r"                 }
assert { parse :eol, "\r\n"               }
assert { noparse :eol, "\n\r"                         }
assert { noparse :eol, "  "                           }
assert { parse :string, '"foo"'                       }
assert { parse :require_action, %{require "foo" \n}   }





