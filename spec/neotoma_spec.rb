# 
#

require 'spec'
$: << 'src'
$: << '../src'
require 'neotoma'


describe Neotoma::Parser do
  it "Should be constructable with a block" do
    parser = Neotoma::Parser.new do 
    end
  end
  
  it "Should be constructable without a block" do
    parser = Neotoma::Parser.new 
  end


end





