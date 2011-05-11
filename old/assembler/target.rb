# The target class abstracts a target CPU the assembler may be targeting
# Targets are all singleton classes
 
require 'singleton'
 
class Target
  include Singleton

  # Autoload known targets 
  autoload :M6507, 'target/m0657.rb'

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
    # Block to be called on assembly
    attr_reader :block
    
    def initialize(code, size, name, desc = nil, &block)
      @code = code.to_i
      @size = size.to_i
      @name = name.to_s
      @desc = desc.to_s || name.to_s
      @block= block
    end
    
  end


  # Operations that the CPU knows, as well as any pseudo operation
  atrr_reader :operation_by_code  
  # Operations that the CPU knows, as well as any pseudo operation
  atrr_reader :operation_by_name
  
  def initialize()  
    @operation_by_code = {}
    @operation_by_name = {}    
  end
  
  # adds another known operation to this target CPU
  def operation(code, size, name, desc = nil, &block)
    inst = Operation.new(code, size, name, desc, &block)
    @operation_by_code[inst.code] = inst
    @operation_by_name[inst.name.downcase.to_sym] ||= []
    @operation_by_name[inst.name.downcase.to_sym] << inst
  end
  
  def self.operation(code, size, name, desc = nil, &block)
    self.instance.operation(code, size, name, desc, &block)
  end
  
  def lookup_name(name)
    return @operation_by_name[name.downcasde.to_sym]
  end



end

