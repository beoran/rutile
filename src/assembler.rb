# An assembler is a generic assembler for any CPU or output format.
# It supports the following features:
# * A buffer containing the information  
# * An index or origin which determines where the current instruction will 
# be assembled.
# * Labels which encode a location of offset  
# * Instructions and pseudo instructions defined by the architecture.  
# * Support for higher level ideas like exported or imported functions or 
# global variables if the output format supports it
# 
# In a later stage a parser could be aded. For now, everything is implmented 
# as a ruby DSL (Domain Specific Language).
if __FILE__ == $0
  $: << '.'
  require 'format'
  require 'target'
else 
  require 'format'
  require 'target'
end
   
class Assembler
  # the output Format instance 
  attr_reader :format
  # Target cpu we are assembling for
  attr_reader :target
  # Outlist is a list of instructions that will end up in the output format
  attr_reader :outlist
  attr_reader :labels
  attr_reader :macros
  
  attr_reader :origin
  
  
  # An instruction is anuthing that may end up in the assembler output
  # Labels are stored in here too because they do end up in the output,
  # but not at the place where they appear, but in the place where they 
  # are referred to. 
  class Instruction
    # operation that instruction performs if any
    attr_reader :operation 
    # operands tha the unstruction has
    attr_reader :operands
    # Assumed origin the instruction will be assembled at.
    attr_reader :origin
    def initialize(operation, operands, origin)
      @operation  = operation
      @operands   = operands
      @origin     = origin
    end
  end
  
  class Label
    attr_reader :name
    attr_reader :global
    attr_reader :origin
    def initialize(n, g, o)
      @name   = n.to_sym
      @global = g
      @origin = o.to_i
    end
    
    # Can be easily used as a number when resolved.
    def to_i
      return @origin
    end
    
  end
  
  FORMATS = { :bin   => Format::Bin   } 
  TARGETS = { :m6507 => Target::M6507 }
  
  def self.format_for(name)
    return FORMATS[name.downcase.to_sym]
  end
  
  def self.target_for(name)
    return TARGETS[name.downcase.to_sym]
  end
  
  # Creates a new assembler with the given output and cpu 
  def initialize(form = :bin, targ = :m6507)
    @labels     = {}
    @outlist    = []
    self.format = form
    self.target = targ
    @origin     = 0
  end
  
  # Sets the target CPU for the assembler
  def target=(targ)
    if targ.respond_to? :instance
      @target = target.instance
    else
      targclass = self.class.target_for(targ)
      raise "Unknown target #{targ}!" unless targclass
      @target = targclass.instance()
    end
  end
  
  # Sets the format of the assembler's output.
  # Any old output will be discarded
  def format=(form)
    if form.respond_to? :new
      @format = form.new
    else
      formclass = self.class.format_for(form)
      raise "Unknown format #{form}!" unless formclass
      @format = formclass.new()
    end
  end
  
  # updates the origin
  def origin=(ori)
    raise "Negative origin not allowed." if ori < 0
    @origin = ori
  end
   
  # Adds a label to the label hash. Labels are case sensitive 
  def label(name, global=true) 
    label               = Label.new(name, global, self.origin)
    @labels[label.name] = label
  end
  
  # Looks up a label. Returns nil if (yet) undefined.
  def lookup_label(name)
    @labels[name.to_sym]
  end
  
  alias :lbl :label

  # Use method_missing to look up the target's opcodes.
  def method_missing(method, *args)
    p "method_missing", method, args, self.target
    op = self.target.lookup_operation(method)
    if !op
      # Not an opcode. Try it as an instruction to the format in stead.
      if @format.respond_to? method
        return @format.send(method, *args)
      end
      # Otherwise complain.
      raise "Unknown opcode #{method}"
    end
    @outlist   << Instruction.new(op, args, self.origin)
    self.origin += op.size
  end

  # Assembles using a DSL.
  def assemble(&block)
    instance_eval(&block)
    resolve
  end
  
  # Resloves the labels and generates the code
  def resolve
    for instruction in outlist do
      operation = instruction.operation
      operation.block.call(self, operation, 
                           *instruction.operands, instruction.origin)
    end
  end


end


if __FILE__ == $0
  asm = Assembler.new()
  asm.assemble do
    format = :bin
    target = :m6507
    
    lbl :reset
    
    nop :foo, 123
    
  
  
  
  end
  asm.format.overwrite('tmp.bin')




end




