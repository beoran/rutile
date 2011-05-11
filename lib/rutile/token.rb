module Rutile
  class Token
    attr_reader :line
    attr_reader :kind
    attr_reader :value
    attr_reader :column
    
    def initialize(kind, value, lineno = 1, column = 1)
      @line    = lineno
      @value   = value
      @kind    = kind
      @column  = column
    end
    
    def error?
      return @kind == :error
    end
    
    def eof?
      return @kind == :eof
    end
    
  end
end  