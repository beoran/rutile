#encoding: utf-8
require 'scanner'
  
  
class Lexer
  class Lexeme
    attr_reader :name
    attr_reader :pattern    
    def initialize(name, pattern)
      @name     = name.to_sym
      @pattern  = pattern 
  
    end
  end
  
  attr_reader :lineno
  
  def initialize(input)
    @scanner = Scanner.new(input)
    @lexemes = []
    @lineno   = 1
  end
  
  def lexeme(name, pattern)
    @lexemes << Lexeme.new(name, pattern) 
  end
  
  def keyword(name)
    pattern = %r{#{name}(?![^ \\\t\n\r])}
    lexeme(name, pattern)
  end
  
  def get_token()
    for lex in @lexemes
      res = @scanner.scan(lex.pattern)
      if res
        @lineno += (res.split(/(\r\n|\n|\r)/).size - 1)
        return [ lex.name, res ]
      end
    end   
    return nil
  end 
  
  def tokenize()
    result = []
    while !@scanner.eos?
      tok = get_token()
      if !tok
        p @scanner
        p result
        raise "Syntax error: cannot find any matching tokens at #@lineno."
        return nil
      end
 
      result << tok
    end
    return result
  end  
  
  
end


if __FILE__ == $0
  
  data   = DATA.read
  lexer  = Lexer.new(data)
  lexer.lexeme(:c_comment         , %r{(?m)/\*(.*?)\*/})
  lexer.lexeme(:cpp_comment       , %r{//([^\r\n].*?)(\r\n|\n|\r)})
  lexer.lexeme(:shell_comment     , %r{#([^\r\n].*?)(\r\n|\n|\r)})
  lexer.lexeme(:float             ,%r{[0-9][0-9_]*\.[0-9]*([eE]?[+-]?[0-9]+)?})
  lexer.lexeme(:integer           ,%r{(0x)?[0-9][0-9_]*})  
  
  btstring_re = %r{`(((\\`)|[^`])*?)`}mx
  lexer.lexeme(:btstring          , btstring_re)    
  sqstring_re = %r{'(((\\\')|[^\'])*?)'}mx 
  lexer.lexeme(:sqstring          , sqstring_re)    
  dqstring_re = %r{"(((\\\")|[^\"])*?)"}mx 
  lexer.lexeme(:dqstring          , dqstring_re)
  
  
  
  lexer.lexeme(:dqsymbol          , dqstring_re)
  id_re       = %r{[a-z][a-z0-9\_\-\+]+}mx
  
  
  lexer.keyword(:if)
  lexer.keyword(:for)
  lexer.keyword(:end)
  lexer.keyword(:jumptolabel)
  lexer.keyword(:jumplabel)
  lexer.keyword(:var)
  lexer.keyword(:typedef)
  lexer.keyword(:struct)
  lexer.keyword(:byte)
  lexer.keyword(:int8)
  lexer.keyword(:int16)
  lexer.keyword(:int32)
  lexer.keyword(:int64)
  lexer.keyword(:int128)
  lexer.keyword(:uint8)
  lexer.keyword(:uint16)
  lexer.keyword(:uint32)
  lexer.keyword(:uint64)
  lexer.keyword(:uint128)
  lexer.keyword(:float32)
  lexer.keyword(:float64)
  lexer.keyword(:void)
  lexer.keyword(:int)
  lexer.keyword(:uint)
  lexer.keyword(:float)
  lexer.keyword(:uintptr)
  lexer.keyword(:pointer)
  lexer.keyword(:switch)
  lexer.keyword(:break)
  lexer.keyword(:def)
  lexer.keyword(:func)
  lexer.keyword(:interface)
  lexer.keyword(:select)
  lexer.keyword(:case)
  lexer.keyword(:defer)
  lexer.keyword(:else)
  lexer.keyword(:package)
  lexer.keyword(:const)
  lexer.keyword(:fallthrough)
  lexer.keyword(:range)
  lexer.keyword(:continue)
  lexer.keyword(:import)
  lexer.keyword(:true)
  lexer.keyword(:false)
  lexer.keyword(:public)
  lexer.keyword(:private)
  lexer.keyword(:return)
  
  # lexer.keyword(:)
  
  symbol_re = %r{:[^ \t\n\r]+}
  lexer.lexeme(:symbol            , symbol_re)
  
  id_re       = %r{[a-z][^ \t\n\r\n]+}mx
  lexer.lexeme(:identifier        , id_re)
  
  const_re    = %r{[A-Z][^ \t\n\r\n]+}mx
  lexer.lexeme(:constant          , const_re)
  
  custop_re   = %r{[\+\-\*\/\!\&\^\%\=\|<>]+}mx
  lexer.lexeme(:custom_operator   , custop_re)
  lexer.lexeme(:escaped_nl        , %r{\\(\r\n|\n|\r)})
  lexer.lexeme(:sep               , %r{\;})  
  lexer.lexeme(:nl                , %r{(\r\n|\n|\r)})
  lexer.lexeme(:gws               , %r{[ \t\n\r]+})
  
  
  tokens = lexer.tokenize()
  p tokens
  p lexer.lineno
  
end


__END__

func main a int b int32 return void\
  a ; b

end

if foo == bar
  for foo 
  end
end
:symbol
:symbols-can+contain*anything_that(is)}{not'"a_space

*/-+-***!!!&&&<=><-->

Constant*are*much*the*same

CamelCase
Lisp-Style-Constant

identifier_can+do$it-too

ident+2

lisp-style-identifier

underscore_style_identifier



"hello\" escaped"

"hello \q world"

'Single 
quoted \' string'

`Backtick
Quoted \`
string`





 1  
 0 
 2
  
    
12.3
0.5

1.

42.e01
42.55e21

42.55e-21
420_256.55E+21

0x1234567
01234578
123_456_789

/* 
 A C comment 
*/  

# and another

# A shell comment package "main"

// A C++ comment


