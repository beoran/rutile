# The target class abstracts a target CPU the assembler may be targeting
# Targets are all singleton classes
 
require 'singleton'
 
class Target
  include Singleton

  # Autoload known targets 
  autoload :M6507, 'target/m6507.rb'

  # The Operation class holds information about operations that 
  # the CPU supports and how to assemble them. 
  class Operation
    # Opcode of the instruction. 
    # Must be unique since it's used to look up by hash.
    attr_reader :code
    # Short name of instruction
    attr_reader :name
    # Long description. 
    attr_reader :desc
    # Size in bytes of full instruction with operand data
    attr_reader :size
    # Timing of instruction
    attr_reader :time
    # Block to be called on assembly
    attr_reader :block
    
    def initialize(code, size, name, timing, desc = nil, &block)
      @code = code.to_i
      @size = size.to_i
      @name = name.to_s
      @time = timing.to_s
      @desc = desc.to_s || name.to_s      
      @block= block
    end
    
  end


  class Register
    attr_reader :name
    attr_reader :size
    def initialize(name, size)
      @name = name.to_sym
      @size = size.to_i
    end
  end

  # Operations that the CPU knows, as well as any pseudo operation
  attr_reader :operation_by_code  
  # Operations that the CPU knows, as well as any pseudo operation
  attr_reader :operation_by_name
  
  def initialize()  
    @operation_by_code = {}
    @operation_by_name = {}
    @registers         = {}
  end
  
  # adds another known operation to this target CPU
  def operation(code, size, name, time, desc = nil, &block)
    inst = Operation.new(code, size, name, time, desc, &block)
    @operation_by_code[inst.code] = inst 
    @operation_by_name[inst.name.downcase.to_sym] = inst
  end
  
  def lookup_operation(name)
    return @operation_by_name[name.downcase.to_sym]
  end
  
  def lookup_register(name)
    return @registers[name.downcase.to_sym] 
  end
  
  def self.operation(code, size, name, time, desc = nil, &block)
    return self.instance.operation(code, size, name, time, desc, &block)
  end
  
  def self.lookup_operation(name)
     return self.instance.lookup_operation(name)
  end
  
  def self.lookup_register(name)
     return self.instance.lookup_register(name)
  end
    
end

