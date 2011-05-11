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
      @before  = nil
      @stack   = []
      @now     = nil
      @end_of_line = false
    end 
    
    KEYWORDS   = %w{func struct var require}
    
    PUNCTUATORS = %w{[ ] ( ) { } . -> ++ -- & * + - ~ ! / % << >> < > <= >= 
         ? : ; ... = *= /= %= += -= <<= , # ## <: :> <% %> %: %:%: 
         == >>= != &= ^ | ^= && || |=}
    
    # Are we on the next, new line after a getc?
    def new_line?
      # First char is not set, so we're beginning the scan. Not on a new line.
      return false unless @last 
      # Previous char was newline , so now we're on a new line
      return true if @last == "\n"
      return (@last == "\r") && (@now != "\n")
      # Previous char was carriage return, so now we're on a new line
      # UNLESS the currect character is a \n, in whic case we're in the 
      # middle of a \\r\n, and don't have a new line yet 
    end
    
    def advance()
      if new_line? 
        @line   += 1
        # advance one line
        @lastcol = @column
        # remember last column
        @column  = 0
        # start in col zero
      end
      # next colmn
      @column  += 1
    end
    
    def recede
      if new_line?
        @line   -= 1
        @column  = @lastcol
      end
      @column  -= 1
    end

    def getc
      return nil if @stream.eof?
      @before = @last
      @last   = @now
      @now    = @stream.getc
      advance()
      return @now
    end
    
    def ungetc()
      recede()
      @stream.ungetc(@now)
      @now  = @last
      @last = @before
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
    
    def error(text)
      return token(:error, text)
    end
    
    def eof?
      @stream.eof?
    end
    
    
    
    def want(re_or_str)
      return nil if @stream.eof?
      self.getc
      if re_or_str === self.now
        return self.now
      else
        self.ungetc
        return nil
      end 
    end
    
    OPERATOR_RE   = /[\+\-\*\/\<\>\&\!\=\^\|\~]/
    WHITESPACE_RE = /[ \t]/
    ENDLINE_RE    = /[\r\n]/
    ENDEMPTYLINE_RE = /[\r\n \t]/
    SYMBOL_RE       = /[A-Za-z0-9\_]/
    
    def gather_until(re_or_str, esc = nil)
      aid = "" + self.now
      ch     = getc
      while ch
        aid  << ch
        if re_or_str === ch && self.last != esc
            return aid
        end
        ch   = getc
      end
      return aid
    end
    
    
    def gather(re, first = '')
      aid     = "" + first + self.now
      ch      = want(re)
      while ch
        aid   << ch
        ch    = want(re)
      end
      return aid
    end
    
    
    # collects characters until they match the re_or_str. If escape is given.
    def collect_until(type, re_or_str, esc = nil)
      aid = gather_until(re_or_str, esc)
      return yield(aid) if block_given?
      return token(type, aid)
    end
    
    # collects characters as long as they match the re and returns it asa result 
    def collect(type, re, first = '')
      aid     = gather(re, first)
      return yield(aid) if block_given?
      return token(type, aid)
    end
    
    def lex_base(base, first, aid2)
      re = /\A[0-9a-fA-F]/
      unless self.getc # swallow the x o or b character        
        return error("Unexpected end of file in numerical constant #{first}#{aid2}")
      end
      aid3 = self.now
      unless re =~ aid3  # check for errors
        self.ungetc
        return error("Unexpected character #{aid3} in numerical constant #{first}#{aid2}")
      end
      return collect(:integer, re) do |aid|
        intval = Integer(aid, base) rescue nil
        if intval
          token(:integer, intval)
        else
          error("Could not understand numerical constant #{first}#{aid2}#{aid}")
        end
      end
    end
    
    def lex_baseint(first)
      aid   = self.getc
      case aid
        when 'b', 'B' 
          return lex_base(2, first, aid)
        when 'o', 'O'
          return lex_base(8, first, aid)
        when 'x', 'X' 
          return lex_base(16, first, aid)
        else
          return lex_floatint(first, aid)
      end
    end
    
    NUMBER_RE = /[0-9eE\+\-\.]/
    
    def lex_floatint(first)
      return collect(nil, NUMBER_RE) do |aid|
        floatval = Float(aid)   rescue nil
        intval   = Integer(aid) rescue nil
        if intval
          token(:integer, intval)
        elsif floatval
          token(:float  , floatval)
        else
          token(:error  , "Could not understand numerical constant #{aid}")
        end
      end
    end
    
    
    def lex_numeric
      first    = self.now
      if first == '0'
        return lex_baseint(first)
      else
        return lex_floatint(first)
      end
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
    
    def lex_identifier
      return collect(:identifier, /[a-zA-Z0-9_!?$]/) do |aid|
        if KEYWORDS.member?(aid) 
          token(aid.to_sym, aid)
        else
          token(:identifier, aid)
        end
      end
    end
    
    def lex_global
      return collect(:global    , /[a-zA-Z0-9_]/)
    end
    
    
    def lex_const(first)
      return collect(:constant , /[a-zA-Z0-9_]/, first)
    end
    
    def lex_type(first)
      return collect(:typename , /[a-zA-Z0-9_]/, first)
    end
    
    
    def lex_const_or_type
      first = self.now
      aid   = self.getc
      case aid
        when /[A-Z]/
          return lex_const(first)
        when /[_a-z]/
          return lex_type(first)
        else
          ungetc
          return lex_const(first)
      end
    end
    
    def lex_string
      return collect_until(:string, self.now, '\\')
    end
    
    def lex_operator
      return collect(:operator, OPERATOR_RE)
    end
    
    def lex_symbol
      return collect(:symbol, SYMBOL_RE)
    end
    
    def lex_comment
      if want('{') 
        collect_until(:coment, '}')
      end
      return collect_until(:comment, /[\r\n]/)
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
        when '$'
          return lex_global
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
          return token(:eof, nil)
        else
          return error("Unknown character #{self.now}")
      end
    end
    
    def lex_skip(*toskip)
      begin
        token = self.lex
        return token if token.error? || token.eof?
      end until !toskip.member?(token.kind)
      return token
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