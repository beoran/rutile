require 'strscan'

if __FILE__ == $0
  $: << '..'
end

require 'dot'
require 'scanner'
require 'lexer'

module Parser
  # A result from parsing. It's a node that has a tree-like structure
  class Result
    attr_reader :children
    attr_reader :parent
    attr_reader :value
    attr_accessor :name
    
    # The rule that produced this result
    attr_reader :rule  
  
    def initialize(rule, value = nil, parent = nil)
      @rule     = rule 
      @value    = value
      @parent   = parent
      @children = []
    end
    
    # Forces the parent to be set to parent
    def force_parent(parent)
      @parent  = parent
    end
    
    # Returns true if this result node has no children
    def leaf?
      return @children.size < 1
    end
    
    # Returns true if this is a branch result node that has children
    def branch?
      return !self.leaf?
    end
    
    # Adds a child to this result if it is not nil nor false
    # Will also force the parent if it isn't set
    def add_child(child)
      return nil   unless child
      @children << child
      child.force_parent(self) unless child.parent
      return       child
    end
    
    # Shorthand for add_child
    def <<(child)
      self.add_child(child)
    end
    
    # Creates a new child for this result  
    def new_child(name, value, klass = Neotoma::Result)
      child     = klass.new(name, value, self)
      return      add_child(child) 
    end
    
    # Walks the result tree recursively, depth-first
    def walk(&block) 
      for child in @children do
        child.walk(&block)
      end
      return block.call(self) 
    end
    
    # Returns the value converted to string only only
    def to_s
      return "#{self.value.text}" if self.value
      return "nil"
    end
    
    def inspect
      return "<#{self.class}: (#{self.rule.name} #{self.to_s})>"
    end
    
    # Converts the results to an S-expression style array  
    def to_a
      result   = [ self.rule.name.to_sym,  self.value ]   
      subarray = []
      for child in self.children
        childarray = child.to_a
        subarray    << childarray 
      end
      result  << subarray
      return result      
    end
    
    # For graphing a result tree to a Dot graph     
    def to_graph_node(graph, parentnode)
      opts        = {}
      label       = "#{self.rule.name}\n#{self.to_s}"
      newparent   = graph.node(nil, label, opts)
      parentnode >> newparent
      
      for child in self.children
        p child
        p child.children
        child.to_graph_node(graph, newparent)
      end
    end
    
    # Returns a Dot graph for this result and it's children.    
    def to_graph(attrs={})
      graph     = Dot::Graph.new(attrs)
      rootnode  = graph.node('root', self.name)
      self.to_graph_node(graph, rootnode)
      return graph
    end 
  end 
end


module Parser

  # A general parser rule 
  class Rule
    attr_reader :name
    attr_reader :parser
    
    def initialize(parser, name)
      @parser = parser
      @name   = name.to_s
    end
    
    def name=(nam)
      @name = nam.to_s
    end
    
    # Makes a result for this rule
    def make_result(value, parent = nil)
      return Result.new(self, value, parent)
    end
    
    # Parse of the input for this rule
    def parse()
        # todo: packrat style caching
        # set a checkpoint   
        @parser.checkpoint
        result            = parse_real()
        if !result 
          # rollback on failure.
          @parser.rollback
        end
        return result
    end
    
    # Parses the input for real. Override this.
    def parse_real()
      return nil
    end
    
    # Converts a name to a terminal rule, but leaves a rule a rule.
    def self.to_rule(parser, other_rule, name = nil)
      return other_rule if other_rule.is_a?(Rule)
      name     ||= other_rule
      other_rule = Terminal.new(parser, name)
      return other_rule
    end
    
    # Converts a name to a terminal rule, but leaves a rule a rule.
    def to_rule(other_rule, name = nil)
      return self.class.to_rule(self.parser, other_rule, name)
    end
    
    
    # Alteration operator
    def | (other)
      return self / other 
    end
    
    # Alteration operator
    def / (other)   # / is the alteration operator
      other_rule = self.to_rule(other)
      return Alternate.new(self.parser, "#{self.name}|#{other.name}", self, other)
    end
    
    # Sequence operator
    def & (other)
      other_rule = self.to_rule(other)
      return Sequence.new(self.parser, "#{self.name}&#{other.name}", self, other) 
    end
    
    # +rule returs a Repetition that means "at least once" 
    def +@
      return Repetition.new(self.parser, "#{self.name}+", self, 1, nil)
    end
    
    # rule.+ also returns a Repetition that means "at least once"
    # if at_most is given, it will limit to this 
    def +(at_most = nil)
      return Repetition.new(self.parser, "#{self.name}+#{at_most}", self, 1, at_most)
    end
    
    # rule.* returs a Repetition that means "at least once"
    # if at_most is given, it will limit to this 
    def *(at_most = nil)
      return Repetition.new(self.parser,"#{self.name}*#{at_most}", self, 0, at_most)
    end
    
    # Negative lookahead.
    def not!()
      return NegativeLookahead.new(self.parser,"#{self.name}!", self)
    end
    
    # Positive lookahead
    def has?()
      return PositiveLookahead.new(self.parser,"#{self.name}!", self)
    end
        
    # rule.any? returns a Repetition that means "once or not at all"    
    def any?
      return Repetition.new(self.parser,"#{self.name}?", self, 0, 1)
    end
       
    # Returns true if the rule is terminal. 
    # Inspects children to find out
    def terminal?
      return self.children.nil?
    end
      
    # Retucns any child rules (for an alteration), etc as an array
    # Returns nil by default.  
    def children
      return nil
    end
    
    # Returns the name only
    def to_s
      return self.name
    end
    
    def inspect
      return "<#{self.class}: (#{self.name})>"
    end

    
    # For graphing to a Dot graph node. Don't override this. 
    def to_graph_node(graph, parentnode)      
      # node already exists, so only link and skip it.
      if graph.nodes[self.name]
        parentnode >> graph.nodes[self.name]
        return nil
      end
      newparent = self_to_graph_node(graph, parentnode)
      return nil unless newparent
      unless self.terminal?
        for subrule in self.children
          subrule.to_graph_node(graph, newparent)
        end
      end
      return newparent
    end
    
    # Graphs self to node. Override this. 
    # Should return new parent node of graph.
    def self_to_graph_node(graph, parentnode)
      opts      = { :shape => :record }
      label     = self.to_s
      newparent = graph.node(self.name, label , opts)
      parentnode >> newparent
      return newparent
    end
  end
  
  # A terminal rule that corresponds to a terminal lexer token
  class Terminal < Rule
     
    def initialize(parser, name) 
      super(parser, name)
    end 
    
    def parse_real()
      found = @parser.get?(self.name)
      return make_result(found) if found
      return nil
    end
    
    def self_to_graph_node(graph, parentnode)
      opts      = { :shape => :ellipse }
      label     = self.name.to_s
      newparent = graph.node(self.name, label , opts)
      parentnode >> newparent
      return newparent
    end
  end
     
  # Sequence of alternatives
  class Sequence  < Rule
    attr_reader :rules
    
    def initialize(parser, name, *rules)
      super(parser, name)       
      
      # meld sequences together
      newrules = []
      for rule in rules.each do
        if rule.is_a? self.class
          newrules = newrules + rule.rules 
        else 
          newrules << rule   
        end
      end
      @rules = newrules
    end
    
    def parse_real()
      result = make_result(nil)
      # We have to be able to get all results
      for rule in @rules do
        subres = rule.parse()
        unless subres
          return nil
        end
        result << subres
      end  
      return result
    end
    
    def children
      return @rules
    end
    
  end
  
  # Choice between two or more alternatives
  class Alternate < Rule
    attr_reader :rules
    def initialize(parser, name, *rules)
      super(parser, name)
      
      # meld alternates together
      newrules = []
      for rule in rules.each do
        if rule.is_a? self.class
          newrules = newrules + rule.rules 
        else 
          newrules << rule   
        end
      end
      @rules = newrules
    end
    
    def parse_real()
      for rule in @rules do
        subres = rule.parse()
        if subres
          return subres
        end
      end  
      return nil
    end

    def children
      return @rules
    end
  end
  
  
  # Positive lookahead
  class PositiveLookahead < Rule
    def initialize(parser, name, rule)
      super(parser, name)
      @rule       = rule
    end
        
    def parse_real()
      @parser.checkpoint
      result = @rule.parse()
      @parser.rollback 
      # need to roll back since parse committed
      
      if result 
        newres = make_result(true)
        newres << result
        return result
      else
        return nil
      end  
    end
  end
  
  # Negative lookahead
  class NegativeLookahead < Rule
    def initialize(parser, name, rule)
      super(parser, name)
      @rule       = rule
    end
        
    def parse_real()
      @parser.checkpoint
      result = @rule.parse(scanner)
      @parser.rollback 
      # need to roll back since parse committed      
      if result
        return nil
      else
      # If no result, scan automatically rolls back
        newres = make_result(true)
        return newres
      end
    end
  end

  
  # Repetition (*, +, {n, m})
  class Repetition < Rule
    def initialize(parser, name, rule, minimum = 0, maximum = nil)
      super(parser, name)
      @rule       = rule
      @minimum    = minimum
      @maximum    = maximum
    end
    
    def parse_real()
      result      = make_result(nil)
      @repeat     = 0
      # First, check if we can parse the rule at least minimum times. 
      while @repeat < @minimum
        subres = @rule.parse()  
        unless subres
          return nil 
        end
        result        << subres
        @repeat       += 1
      end
      
      # Now get @maximum times the result
      while @maximum.nil? || @repeat < @maximum
        subres = @rule.parse()
        # If no more results from scan, just return constructed result
        unless subres
          return result
        end        
        result   << subres 
        @repeat  += 1
      end  
      return result
    end
    
    def children
      return [ @rule ]
    end  
    
  end
  
  # A Placeholder rule is a rule that is yet not defined
  # but that will be defined later with .define_rule
  # Mostly for use internally in the parser
  class Placeholder < Rule
    def initialize(parser, new_name)
      super(parser, new_name)
      @rule = nil
    end
    
    def define_rule(rule)
      @rule = rule
    end
    
    # Changes the name of the defined suprule also if it's available
    def name=(newname)
      @rule.name  = newname if @rule
      @name       = newname
    end
    
    # The parsing step simply forwards the parsing to the rule 
    # which should have been defined through define_rule 
    def parse_real()
      raise "Placeholder rule \'#{self}\' is undefined!" unless @rule
      subres   = @rule.parse()
      if subres 
        result = make_result(nil)
        result << subres
      else 
        result = nil
      end  
      return result
    end

    def children
      return [ @rule ]
    end
      

  end

  
  
  

  



end


module Parser 
  class Parser < Parser::Rule
  
  def initialize(name = 'parser', &block)
    super(self, name)
    @start    = nil
    @rules    = {}
    define_rules(&block) if block
  end
  
  def parse(input)
    @lexer        = RutileLexer.new(input)
    @tokens       = @lexer.tokenize
    @index        = 0
    @active       = []
    @checkpoints  = []
    result        = @start.parse()
    if !result
      warn "Parse error: #{self.peek.lineno} : #{self.peek.colno} #{self.peek}!"
      p @tokens
    end
    return result
  end
  
  def checkpoint
    @checkpoints << @index
    return @index
  end
  
  def rollback
    return nil if @checkpoints.empty? 
    @index = @checkpoints.pop
    return @index
  end
  
  def peek()
    return @tokens[@index] 
  end
  
  def peek?(name)
    tok = peek()
    return false if !tok
    p tok
    return tok.name == name     
  end  
  
  def get()
    tok     = @tokens[@index]
    @index += 1
    return tok
  end
  
  def get?(name)
    return nil if not(peek?(name))
    return get()
  end

    
  def define_rules(&block)
    blockres  = instance_eval(&block)
    @start  ||= blockres 
  end
  
  
  def to_rule(value, name = nil)
    return Rule.to_rule(self, value, name)
  end  

  def rule(value, name=nil)
    return self.to_rule(value, name)
  end
    
  def term(value, name = nil)
      return self.to_rule(value, name)
  end
  
  def t(value, name = nil)
      return self.to_rule(value, name)
  end
  
  def terminal(value, name = nil)
    return self.to_rule(value, name)
  end
  
  def placeholder(name)
    return Placeholder.new(self, name)
  end
    
  # Adds a named rule to the parser, automatically converting 
  # a string, symbol or regexp to a rule.
  # If the rule already existed and was a placeholder (undefined),
  # the placeholder rule will be defined by calling .define_rule
  # on it  
  def []=(key, value)      
    keysym                = key.to_sym
    oldrule               = @rules[keysym]
    if oldrule 
      if oldrule.respond_to?(:define_rule)
        # define rule          
        oldrule.define_rule(value)
      end
      # and rename it anyway
      oldrule.name        = keysym
    else 
      setrule             = self.to_rule(value, keysym)
      @rules[keysym]      = setrule
      # and rename it anyway
      # setrule.name        = keysym
    end
  end
    
  # Returns the rule, or, if 
  # no such rule is defined yet, returns a Placeholder rule, 
  def [](key)
    keysym          = key.to_sym
    rule            = @rules[keysym]
    return rule if rule
    # Return the rule if we have it, otherwise make a placeholder,
    # and store that place holder.
    rule            = placeholder("#{keysym}")
    @rules[keysym]  = rule
    return @rules[keysym]
  end
    
  # Use method_missing to simulate named rules
  def method_missing(name, value = nil)
    if name      =~ /=\Z/
      key        =  name.to_s.gsub('=','') 
      self[key]  =  value 
    else
      return self[name]
    end
  end
    
  # Child nodes
  def children
    return [ @start ] 
  end
    
   # For graphing to a dot graph node
  def to_graph_node(graph, parentnode)
    opts      = {}
    label     = @start.to_s
    newparent = graph.node(nil, label , opts)
    parentnode >> newparent
    unless @start.terminal?
      for subrule in @start.children
        subrule.to_graph_node(graph, newparent)
      end
    end
  end
      
  def to_graph(attrs={})
    graph     = Dot::Graph.new(attrs)
    rootnode  = graph.node('root', self.name)
    self.to_graph_node(graph, rootnode)
    return graph
  end
  
  end
  
end

class RutileParser < Parser::Parser
  
  def initialize()
    super()
    define_rules do
      comment   = t(:c_comment) | t(:shell_comment) | t(:cpp_comment)
      blanks    = (t(:ws)       | t(:nl))
      string    = t(:sqstring)  | t(:dqstring)  
      
      packtl    = t(:package) & t(:ws) & string
      importtl  = t(:import) & t(:ws) & string
      # packtl | importtl   | 
      toplevel  = comment       | blanks
             
      program   = toplevel.+
      self.start= program
    end
  end
end


if __FILE__ == $0
  
  data   = DATA.read
  puts data
  parser = RutileParser.new()
  result = parser.parse(data)
  p parser.active
  parser.to_graph.display
  result.to_graph.display if result
  
  
end


__END__



# import "foo"

// also comment




