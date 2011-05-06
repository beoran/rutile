require 'stringio'

module Rutile
  class Lexer
    def initialize(stream)
      @line    = 1
      @column  = 0
      @lastcol = 0
      @stream  = stream 
      if @stream.respond_to?(:to_str)
        @stream = StringIO.new(@stream)
      end
      @last    = nil
      @stack   = []
      @now     = nil
      @end_of_line = false
    end 
    
    KEYWORDS   = %w{func struct var}
    
    PUNCTUATORS = %w{[ ] ( ) { } . -> ++ -- & * + - ~ ! / % << >> < > <= >= 
         ? : ; ... = *= /= %= += -= <<= , # ## <: :> <% %> %: %:%: 
         == >>= != &= ^ | ^= && || |=}
    
    def getc
      return nil if @stream.eof?
      @last = @now
      @now  = @stream.getc
      advance(@now)
      return @now
    end
    
    def ungetc()
      recede(@now)
      @stream.ungetc(@now)
      @now = @last
      return @now
    end
    
    def last
      @last
    end
    
    def now
      @now
    end
    
    def token(kind, value)
       return Token.new(kind, value, @line, @column)
    end
    
    def eof?
      @stream.eof?
    end
    
    def advance(char)
      if @end_of_line
        @line   += 1
        @lastcol = @column
        @column  = 0
        @end_of_line = false
      end
      if (char == "\n") ## Won't work on mac, I guess...
        @end_of_line =true 
      end      
      @column  += 1
    end
    
    def recede(char)
      if @end_of_line
        @line   -= 1
        @column  = @lastcol
        @end_of_line = false
      end
      if (char == "\n") ## Won't work on mac, I guess...
        @end_of_line = true 
      end      
      @column  -= 1
    end
    
    
    def want(re_or_str)
      return nil if @stream.eof?
      aid = @stream.getc
      if (re_or_str === aid)
        advance(aid)
        return aid
      else
        @stream.ungetc(aid)
        return nil
      end 
    end
    
    OPERATOR_RE   = /[\+\-\*\/\<\>\&\!\=\^\|\~]/
    WHITESPACE_RE = /[ \t]/
    ENDLINE_RE    = /[\r\n]/
    ENDEMPTYLINE_RE = /[\r\n \t]/
    
    # collects characters as long as they match the re and returns it asa result 
    def collect(type, re)
      aid = ""
      ch = want(re)
      while ch
        aid << ch
        ch = want(re) 
      end
      return token(type, aid) # unless
#       ungetc
#       result = token(type, aid)
      return result 
    end
    
    def lex_operator
      return collect(:operator, OPERATOR_RE)
    end
    
    def lex_whitespace
      return collect(:space, WHITESPACE_RE)
    end
    
    
    def lex_newline
      # also skips over whitespace and line endings until we get soething more
      # interesting
      return collect(:endline, ENDEMPTYLINE_RE)
    end
    
    def lex_endline
      return token(:endline, self.now)
    end
    
    
    def lex
      @now = getc
      case self.now
        when /[0-9]/ 
           return lex_numeric
        when /[a-z_]/
          return lex_identifier
        when /[A-Z]/
          return lex_const_or_type
        when /[\'\"]/
          return lex_string
        when '#'
          return lex_comment  
        when '@'
          return lex_member
        when WHITESPACE_RE
          return lex_whitespace
        when ENDLINE_RE
          return lex_newline
        when ';'
          return lex_endline
        when OPERATOR_RE
          return lex_operator
        when ':'
          return lex_symbol
        when /[\(\)\{\}\[\]]/
          return result(self.now.to_sym, self.now)
        when '\\'
          return lex_escape  
        when nil 
          # end of file
          return nil
        else
          return lex_unknown
      end
    end
    
    def self.lex(io)
      lexer = self.new(io)
      return lexer.lex, lexer 
    end
    
    
  end
end  

if $0 == __FILE__
  p Rutile::Lexer.lex('++   ')
  
  

end