require 'test_helper'
require 'rutile/node'

assert { Rutile::Node }

node = nil
assert { node = Rutile::Node.new(:root) }
node2 = nil
assert { node2 = Rutile::Node.new(:leaf) }
assert { node << node2 }
assert { node.nodes.member?(node2) }
assert { node2.trunk == node }
assert { node2.kind == :leaf } 
assert { node.kind == :root } 
