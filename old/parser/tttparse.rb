if __FILE__ == $0
  $: << '..'
end


require 'treetop'
require 'dot'

# extend the syntax node dynamically 
class Treetop::Runtime::SyntaxNode
  
    
  # For graphing a result tree to a Dot graph
  def to_graph_node(graph, parentnode)
    if self.respond_to?(:interesting?) && self.interesting?
      opts        = {}
      label       = "#{self.class}\n#{self.text_value}"
      newparent   = graph.node(nil, label, opts)
      parentnode >> newparent
    else
      newparent   = parentnode   
    end  
    if self.elements
      for child in self.elements
        child.to_graph_node(graph, newparent)
      end
    end  
  end
      
  # Returns a Dot graph for this result and it's children.    
  def to_graph(attrs={})
    graph     = Dot::Graph.new(attrs)
    label     = "#{self.class}\n#{self.text_value}"
    rootnode  = graph.node('root', label)
    self.to_graph_node(graph, rootnode)
    return graph
  end 
  
end


class RutileSyntax 
  class Node <  Treetop::Runtime::SyntaxNode
    def interesting?
      return true
    end
  end
  
  class Comment < Node
  end
  
end  


if __FILE__ == $0
  $: << '..'

  require 'dot'
  Treetop.load "rutile"



  data    = DATA.read
  parser  = RutileParser.new()
  puts "Starting parse..."
  result  = parser.parse(data)
  if result 
    p result
    result.to_graph.display
  else
    puts "parse failed"
    puts parser.methods - Object.methods
    puts parser.failure_reason
     
  end
  


end


__END__
# this is a comment

// this is also a comment
/* And this is also a comment */

