module Rutile
  class Token
    attr_reader :line
    attr_reader :kind
    attr_reader :text
    attr_reader :coln
    
    def initialize(kind, text, lineno = 1, coln = 1)
      @line    = lineno
      @text    = text
      @kind    = kind
      @coln    = coln
    end
  end
end  