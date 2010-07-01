#encoding: utf-8
require 'scanner'
  
# A regexp based lexer that simply tries all 
# defined lexemes in the order they were defined.
# This allows a clear hierarchy of lexemes.

class Lexer
  class Token
    attr_reader :lexeme
    attr_reader :text
    attr_reader :lineno
    attr_reader :colno
    
    def initialize(lexeme, text, lineno, colno)
      @lexeme = lexeme
      @text   = text
      @lineno = lineno
      @colno  = colno
    end
    
    def name
      '(anonymous)'.to_s if !@lexeme
      @lexeme.to_s
    end
    
    def to_s
      return "[#{self.name} #@text (#@lineno #@colno)]"
    end
    
    
  end
  
  class Lexeme
    attr_reader :name
    attr_reader :pattern
    def initialize(name, pattern)
      @name     = name.to_sym
      @pattern  = pattern
    end
    
    def to_s
      return "#@name"
    end
    
  end
  
  attr_reader :lineno
  
  def initialize(input)
    @scanner = Scanner.new(input)
    @lexemes = []
    @lineno  = 1
    @colno   = 1
  end
  
  def lexeme(name, pattern)
    @lexemes << Lexeme.new(name, pattern)
  end
  
  def keyword(name)
    escname = Regexp.escape(name)
    pattern = %r{#{escname}(?![^ \\\t\n\r\;])}
    lexeme(name.to_sym, pattern)
  end
  
  def operator(oper)
    escoper = Regexp.escape(oper)
    pattern = %r{#{escoper}}
    lexeme(oper.to_sym, pattern)
  end
  
  
  def get_token()
    for lex in @lexemes
      res = @scanner.scan(lex.pattern)
      if res
        old_lineno = @lineno
        old_colno  = @colno
        parts    = res.split(/(\r\n|\n|\r)/)
        @lineno += (parts.size - 1)
        if parts.size > 1
          @colno = parts.last.size
        else
          @colno += parts.first.size
        end
        return Token.new(lex.name, res, old_lineno, old_colno)
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
        raise "Syntax error: cannot find any matching tokens
        at #@lineno:#@colno."
        return nil
      end
      result << tok
    end
    return result
  end  
  
  
end


class RutileLexer < Lexer 
  def initialize(data)
    super(data)
    rutile_rules 
  end
  
  def rutile_rules
    lexer = self
    lexer.lexeme(:docstring         , %r{(?m)/\*\*(.*?)\*/})
    lexer.lexeme(:c_comment         , %r{(?m)/\*(.*?)\*/})
    lexer.lexeme(:cpp_comment       , %r{//([^\r\n].*?)(\r\n|\n|\r)})
    lexer.lexeme(:shell_docstring   , %r{##([^\r\n].*?)(\r\n|\n|\r)})
    lexer.lexeme(:shell_comment     , %r{#([^\r\n].*?)(\r\n|\n|\r)})
    lexer.lexeme(:float             ,%r{[0-9][0-9_]*\.[0-9]*([eE]?[+-]?[0-9]+)?})
    lexer.lexeme(:integer           ,%r{(0x)?[0-9][0-9_]*})  
    
    btstring_re = %r{`(((\\`)|[^`])*?)`}mx
    lexer.lexeme(:btstring          , btstring_re)    
    sqstring_re = %r{'(((\\\')|[^\'])*?)'}mx 
    lexer.lexeme(:sqstring          , sqstring_re)    
    dqstring_re = %r{"(((\\\")|[^\"])*?)"}mx 
    lexer.lexeme(:dqstring          , dqstring_re)
      
    dqsymbol_re = %r{\:"(((\\\")|[^\"])*?)"}mx
    lexer.lexeme(:dqsymbol          , dqsymbol_re)
    
    sqsymbol_re = %r{\:'(((\\\')|[^\'])*?)'}mx
    lexer.lexeme(:sqsymbol          , sqsymbol_re)
    
    
    lexer.operator(';')
    lexer.operator('..')
    lexer.operator('.')
    lexer.operator('::')
    lexer.operator(':')
    lexer.operator(',')
    lexer.operator(')')
    lexer.operator('(')
    lexer.operator('}')
    lexer.operator('{')
    lexer.operator('[]')
    lexer.operator('[')
    lexer.operator(']')
    
    lexer.operator('+=')
    lexer.operator('+=')
    lexer.operator('--=')
    lexer.operator('-=')
    lexer.operator('**=')
    lexer.operator('*=')
    lexer.operator('/=')
    lexer.operator('||=')
    lexer.operator('|=')
    lexer.operator('^^=')
    lexer.operator('^=')
    lexer.operator('&&=')
    lexer.operator('&=')
    lexer.operator('@@=')
    lexer.operator('@=')
    lexer.operator('=')
    lexer.operator('!!=')
    lexer.operator('!=')
    lexer.operator('%%=')
    lexer.operator('%=')
    lexer.operator('??=')
    lexer.operator('?=')
    lexer.operator('~=')
    lexer.operator('~~=')
    lexer.operator('<<=')
    lexer.operator('>>=')
    lexer.operator('==>')
    lexer.operator('<==')
    lexer.operator('<=')
    lexer.operator('>=')
    lexer.operator('=>')
    lexer.operator('=<')
    
    lexer.operator('==')
    lexer.operator(':=')
    lexer.operator('=')
    lexer.operator('++')
    lexer.operator('+')
    lexer.operator('--')
    lexer.operator('->')
    lexer.operator('-')
    lexer.operator('**')
    lexer.operator('*')
    lexer.operator('/')
    lexer.operator('||')
    lexer.operator('|')
    lexer.operator('^^')
    lexer.operator('^')
    lexer.operator('&&')
    lexer.operator('&')
    lexer.operator('@@')
    lexer.operator('@')
    lexer.operator('!!')
    lexer.operator('!')
    lexer.operator('%%')
    lexer.operator('%')
    lexer.operator('~~')
    lexer.operator('~')
    lexer.operator('??')
    lexer.operator('?')
    lexer.operator('<->')
    lexer.operator('<=>')
    lexer.operator('<-')
    lexer.operator('<<')
    lexer.operator('<')
    lexer.operator('>')
    lexer.operator('>>')
 
    symbol_re = %r{:[^ \t\n\r\\]+}
    lexer.lexeme(:symbol  , symbol_re)

    lexer.keyword(:nil)
    lexer.keyword(:and)
    lexer.keyword(:or)
    lexer.keyword(:not)
    lexer.keyword(:xor)
    lexer.keyword(:bitand)
    lexer.keyword(:bitor)
    lexer.keyword(:bitxor)
    lexer.keyword(:bitnot)
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
    lexer.keyword(:extend)
    lexer.keyword(:require)
    lexer.keyword(:rescue)
    lexer.keyword(:panic)
    lexer.keyword(:ensure)
    lexer.keyword(:do)
    lexer.keyword(:begin)
    lexer.keyword(:then)
    lexer.keyword(:true)
    lexer.keyword(:false)
    lexer.keyword(:public)
    lexer.keyword(:private)
    lexer.keyword(:return)
    
    # lexer.keyword(:)
    
    const_re    = %r{[A-Z][^ \t\n\r\n\;\.\[\]\(\)\{\}\\]*}mx
    lexer.lexeme(:constant          , const_re)
    
    custop_re   = %r{[\+\-\*\/\!\&\^\%\=\|<>\[\]\.]+}mx
    lexer.lexeme(:custom_operator   , custop_re)
    
    id_re       = %r{[^ \t\n\r\n\;\.\[\]\(\)\{\}\\]+}mxu
    lexer.lexeme(:identifier        , id_re)
    
    
    lexer.lexeme(:escaped_nl        , %r{\\(\r\n|\n|\r)})
      
    lexer.lexeme(:nl                , %r{(\r\n|\n|\r)})
    lexer.lexeme(:ws                , %r{[ \t]+})
    # This final rule ensures that tokenization always works
    # even though it may produce garbage
    lexer.lexeme(:garbage           , %r{.*}mxu);
  end

end


if __FILE__ == $0
  
  data   = DATA.read
  lexer  = RutileLexer.new(data)
  res    = lexer.tokenize()
  p res
  
end


__END__


func puts str * byte : return int : ccall

func foo b int, c int, d int : return int, int : asmcall

func foo b int, c int, d int : return int, int : fastcall




foo.bar
:symbol
:'single quoted symbol with \' escape'
variable[with-index]
variable{ with-block } 
µunicode-is-okµµµ

require 'fmt' :foo


func func-tion
end

func main  a  int  b  int32  return  void\
  puts "hello"

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

## shell style docstring

/** 
* C style docstring
**/
