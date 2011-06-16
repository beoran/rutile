module Rutile
  # a node is a node in the AST that the parser produces.
  class Node
    attr_reader   :kind
    attr_reader   :value
    attr_accessor :trunk
    attr_reader   :nodes
    
    def initialize(kind, value = nil, trunk = nil, nodes = [])
      @kind   = kind
      @value  = value
      @trunk  = trunk
      @nodes  = nodes || []
    end
    
    def <<(node)
      @nodes << node
      node.trunk = self
    end
    
  end
end
    
    
  