#
# Trying to express Rutile as a plain Ruby DSL first, 
# to find some inspiration for the syntax.
#
#

module Rutile
class DSL
  module CanAssemble
    attr_reader :assembler
  
    def asm_raw(asmstr)
      @assembler ||= ""
      @assembler << asmstr
      return asmstr
    end
  
    def asm(str, *args)
      asmstr = str.gsub(%r{\\[0-9]+}) do |m| 
        n = m[1..(m.size)].to_i - 1 
        args[n]
      end
      asmstr << "\n"
      self.asm_raw(asmstr)
    end
  end
  
  
  include CanAssemble
  
  class Int
  end
  
  class Float
  end
  
  # Creates a macro caller on the instance
  def self.make_inline_caller(_name)    
    define_method(_name.to_sym) do |*args|
      return self.call_inline(_name.to_sym, *args)
    end
  end
  
  
  
  def initialize(&block)
    @assembler  = ''
    @inlines    = {}
    @vars       = {}
    instance_eval(&block)
  end
  
  def int(v)
    return v.to_i
  end
  
  def float(v)
    return v.to_f
  end
  
  
  class Inline
    include CanAssemble
    attr_reader :name
    attr_reader :args
    def initialize(name, *args, &block)
      @name       = name.to_sym
      @args       = args.dup
      @assembler  = ''
      @inlines    = {}
      @vars       = {}
      @block      = block
    end
    
    def call(*args)
      res = @block.call(*args)
      return @assembler
    end
  end
  
  def inline(name, *args, &block)
    i                 = Inline.new(name, *args, &block)
    @inlines[i.name]  = i
    self.class.make_inline_caller(i.name)
  end
  
  def call_inline(name, *args)
    inl     = @inlines[name]
    asmraw  = inl.call(*args)
    self.asm_raw(asmraw)
  end
  
  def var(*args)
  end
  
end



 
  def self.primitive(&block)
    rutile = DSL.new(&block)
    puts rutile.assembler
  end
end  

if $0 == __FILE__ 

Rutile.primitive do
  inline :linux_syscall_raw do 
    asm("int $0x80")
  end
    
  inline :linux_syscall_0 do | callnr |
    asm('movl $\1, %eax' , callnr)
    :linux_syscall_raw
  end  
  
  
  call_inline :linux_syscall_0, 1
  # call_inline :linux_syscall_raw
  
end

end