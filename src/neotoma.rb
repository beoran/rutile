# encoding: UTF-8
#
# Copyright Beoran, 2010. Released under GPL v3.
# Neotoma: a Packrat Parser and Parser Generator.
# "Neotoma" is the partial scientific name for the packrat. 
#

require 'singleton'
require 'strscan'
require 'dot'


module Neotoma

  # A result from parsing. It's a node that has a tree-like structure
  class Result
    attr_reader :children
    attr_reader :parent
    attr_reader :value
    attr_reader :name
    
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
      return value.to_s
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
      label       = "#{self.rule}\n#{self.to_s}"
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

  # The scanner wraps the input string
  class Scanner < StringScanner
    attr_reader :checkpoints
  
    def initialize(string)
      super(string)
      @checkpoints = [] # Stack of checkpoints
    end
   
    # Commits the current position as a checkpoint. Returns self.
    def commit()
      @checkpoints << self.pos
      return self
    end
       
    # Rolls back to the previous checkpoint. returns self. 
    # Raises an exception if the checkpoit stack is empty. 
    def rollback()
      oldpos    = @checkpoints.pop
      raise "Checkpoint stack underflow in scanner!" unless oldpos
      self.pos  = oldpos
      return self    
    end
    
    # Scans for the regular expression pattern, and commits the position 
    # if the scan was sucessful.
    # Returns the result of the scan, or nil if the scan failed. 
    # If the scan was sucessful, it will add a commit point as well
    # automatically.
    def scan_commit(pattern)
      result      = self.scan(pattern)
      self.commit if result
      return result
    end 
   
  end 

  # A general parser rule 
  class Rule
    attr_accessor :name
    
    def initialize(name)
      @name = name
    end
    
    # Makes a result for this rule
    def make_result(value, parent = nil)
      return Result.new(self, value, parent)
    end
    
    # Cached parse of the input for this rule
    def parse(scanner, cache = {})
      cache_key           = "#{self.object_id}:#{scanner.pos}"
      cached, cached_pos  = cache[cache_key]
      if cached
        scanner.pos       = cached_pos 
        return cache
      else    
        result            = parse_real(scanner)
        cache[cache_key]  = [ result, scanner.pos ]
        return result
      end  
    end
    
    # Parses the input for real. Override this.
    def parse_real(input)
      return nil
    end
    
    # Converts a literal to a literal rule, but leaves a rule a rule.
    def self.to_rule(other_rule, name = nil)
      return other_rule if other_rule.is_a?(Rule)
      name     ||= "#{other_rule}"
      other_rule = Literal.new(name, other_rule)
      return other_rule
    end
    
    # Alteration operator
    def | (other)
      return self / other
    end
    
    # Alteration operator
    def / (other)
      other_rule = self.class.to_rule(other)
      return Alternate.new("#{self}|#{other}", self, other)
    end
    
    # Sequence operator
    def & (other)
      other_rule = self.class.to_rule(other)
      return Sequence.new("{#{self.name}|#{other.name}}", self, other) 
    end
    
    # +rule returs a Repetition that means "at least once" 
    def +@
      return Repetition.new("#{self.name}+", self, 1, nil)
    end
    
    # rule.+ also returns a Repetition that means "at least once"
    # if at_most is given, it will limit to this 
    def +(at_most = nil)
      return Repetition.new("#{self.name}+#{at_most}", self, 1, at_most)
    end
    
    # rule.* returs a Repetition that means "at least once"
    # if at_most is given, it will limit to this 
    def *(at_most = nil)
      return Repetition.new("#{self.name}*#{at_most}", self, 0, at_most)
    end
    
    # rule.any? returs a Repetition that means "once or not at all"    
    def any?
      return Repetition.new("#{self.name}?", self, 0, 1)
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
  
  # A literal (regexp, string or number) rule
  class Literal < Rule 
    def initialize(name, literal = nil) 
      super(name.to_s)
      literal  ||= name
      if literal.is_a?(Regexp)
        @literal = literal
      else
        @literal = Regexp.new(literal.to_s)
      end  
    end 
    
    def parse_real(scanner)
      found = scanner.scan_commit(@literal)
      return make_result(found) if found
      return nil
    end
    
    def self_to_graph_node(graph, parentnode)
      opts      = { :shape => :ellipse }
      lit       = @literal.to_s.gsub('(?-mix:','').chop
      lit.gsub!("\\","\\\\")
      label     = "#{self.to_s}:#{lit}"
      newparent = graph.node(self.name, label , opts)
      parentnode >> newparent
      return newparent
    end    

    
  end
  
  # A keyword rule
  class Keyword < Literal
    # Graphs self to node. 
    def self_to_graph_node(graph, parentnode)
      opts      = { :shape => :circle }
      label     = self.to_s
      newparent = graph.node(self.name, label , opts)
      parentnode >> newparent
      return newparent
    end    
  end
   
  # Sequence of alternatives
  class Sequence  < Rule
    def initialize(name, *rules)
      super(name)
      @rules = rules 
    end
    
    def parse_real(scanner)
      result = make_result(nil)
      # We have to be able to get all results
      for rule in @rules do
        subres = rule.parse(scanner)
        unless subres
          return nil
        end
        result << subres
      end  
      scanner.commit
      return result
    end
    
    def children
      return @rules
    end  
    
  end
  
  # Choice between two or more alternatives
  class Alternate < Rule
    def initialize(name, *rules)
      super(name)
      @rules = rules 
    end
    
    def parse_real(scanner)
      for rule in @rules do
        subres = rule.parse(scanner)
        if subres
          scanner.commit
          return subres
        end
      end  
      return nil
    end

    def children
      return @rules
    end      
  end
  
  # Empty match
  class Empty  < Rule
    include Singleton
    def initialize(name)
      super('(empty)')
    end
    
    def parse_real(scanner)
      return make_result(nil)
    end
        
  end
  
  # Negative or positive lookahead
  class Lookahead < Rule
    def initialize(name, rule, positive = true)
      super(name)
      @rule       = rule
      @positive   = positive
    end
  end
  
  # End of parser input 
  class Endstream < Rule
    include Singleton 
    def initialize(name)
      super('(end of stream)')
    end
  end
  
  # Repetition (*, +, {n, m})
  class Repetition < Rule
    def initialize(name, rule, minimum = 0, maximum = nil)
      super(name)
      @rule       = rule
      @minimum    = minimum
      @maximum    = maximum
    end
    
    def parse_real(scanner)
      result      = make_result(nil)
      @repeat     = 0
      # First, check if we can parse the rule at least minimum times. 
      while @repeat < @minimum
        subres = @rule.parse(scanner)
        unless subres
          return nil 
        end
        result        << subres
        @repeat       += 1
      end
      
      # Now get @maximum times the result
      while @maximum.nil? || @repeat < @maximum
        subres = @rule.parse(scanner)
        # If no more results from scan, just return constructed result
        unless subres
          scanner.commit
          return result
        end        
        result   << subres 
        @repeat  += 1
      end  
      scanner.commit
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
    def initialize(new_name)
      super(new_name)
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
    def parse(scanner, cache={})
      raise "Placeholder rule \'#{self}\' is undefined!" unless @rule
      subres   = @rule.parse(scanner, cache)
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
 
  # A parser parses an input into a parse tree
  # based on it's defined rules
  class Parser < Rule
    
    attr_reader   :start
    attr_reader   :rules
    
    def initialize(name = 'parser', &block)
      super(name)
      @start    = nil
      @scanner  = nil
      @rules    = {}
      define_rules(&block) if block
    end
    
    def define_rules(&block)
      blockres  = instance_eval(&block)
      @start  ||= blockres 
    end
    
    def parse(input)
      @scanner  = Neotoma::Scanner.new(input)
      @cache    = {}
      result    = @start.parse(@scanner, @cache)
      return result
    end

    def to_rule(value, name = nil)
      return Rule.to_rule(value, name)
    end  

    def rule(value, name=nil)
      return self.to_rule(value, name)
    end
    
    def lit(value, name = nil)
      return self.to_rule(value, name)
    end
    
    def keyword(name, nonword='\\W')
      # a keyword is the given name followed by any non-word
      # character or the end of the input 
      kwrule = Regexp.new("#{name}(?=(#{nonword}|\\Z))")
      kw     = Keyword.new("#{name}", kwrule) 
      return kw # rule(kwrule, )
    end
    
    def placeholder(name)
      return Placeholder.new(name)
    end
    
    # Adds a named rule to the parser, automatically converting 
    # a string or regexp to a rule.
    # If the rule already existed and was a placeholder (undefined),
    # the placeholder rule will be defined by calling .define_rule
    # on it  
    def []=(key, value)      
      oldrule               = @rules[key.to_sym]
      if oldrule && oldrule.respond_to?(:define_rule)
        # define rule and rename it 
        oldrule.define_rule(value)
        oldrule.name        = key.to_sym
      else 
        setrule             = self.to_rule(value, "#{key}")
        @rules[key.to_sym]  = setrule
      end        
    end
    
    # Returns the rule, or, if 
    # no such rule is defined yet, returns a Placeholder rule
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
    
    def children
      return [ @start ] 
    end
    
     # For graphing to a dot graph node
     def to_graph_node(graph, parentnode)
       opts  = {}
       label = @start.to_s
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



if $0 == __FILE__
  
s = %q{do do end end}

parser       = Neotoma::Parser.new do  
  self.program    = (self.block / self.white_word).*
  self.whitespace = '\W+'
  self.word       = '\w+'
  self.key_do     = keyword('do'  , '\W+')
  self.key_end    = keyword('end' , '\W+')
  self.brace_open = '{'
  self.brace_close= '}'
  self.white_word = self.key_do / word / whitespace
  self.inblock    = (self.block / self.white_word).*
  self.doblock    = self.key_do & self.inblock & self.key_end
  self.braceblock = brace_open & inblock & brace_close
  self.block      = doblock / braceblock 
  start           = self.doblock
end

# p parser.rules
# parser.to_graph.display

results           = parser.parse(s)
results.to_graph.display
# p results
p results

=begin
r  = Neotoma::Literal.new('foo')
r2 = (r * 1)
r3 = r.once?
p r
p r2
p r3


ss = Neotoma::Scanner.new(s)
p ss.scan_commit(/\W+/)
p ss.scan_commit(/1/)
p ss.scan_commit(/foo/)
p ss.pos 
p ss.checkpoints
ss.rollback
ss.rollback
p ss.pos
p ss.scan_commit(Regexp.new('foo'))
=end 
 
end
