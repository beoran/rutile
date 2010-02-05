# 
#

require 'spec'
$: << 'src'
$: << '../src'
require 'neotoma'


describe Neotoma::Parser, "class" do
  it "should be constructable with a block" do
    parser = Neotoma::Parser.new do 
    end
  end
  
  it "should be constructable without a block" do
    parser = Neotoma::Parser.new 
  end
  
  it "should be able to parse a single literal word" do
    parser = Neotoma::Parser.new do
      lit('foo')
    end
    txt    = 'foo'
    result = parser.parse(txt)
    result.should_not be_nil  
  end
  
  it "should be able to parse a single literal word, 
      with the literal being named explicitly" do
    parser = Neotoma::Parser.new do
      lit('foo', 'foo')
    end
    txt    = 'foo'
    result = parser.parse(txt)
    result.should_not be_nil
  end
  
  it "should have parse results that can be changed into S-expressions" do
    parser = Neotoma::Parser.new do
      self.foo   = lit('foo', 'foo')
      self.start = self.foo
    end
    txt    = 'foo'    
    result = parser.parse(txt)
    sexpr  = result.to_a
    sexpr.should_not be_nil
    sexpr.should == [:foo, "foo", []]  
  end
  
  it "should be able to partially parse a single literal word from a string" do
    parser = Neotoma::Parser.new do
      lit('foo', :foo)
    end
    txt    = 'foobar'
    result = parser.parse(txt)
    result.to_a.should == [:foo, 'foo', []]
  end  
  
  it "should automagically name literals given as constants in the DSL" do
    parser = Neotoma::Parser.new do
      self.foo = /foo/
      self.start = self.foo
    end
    txt    = 'foo'
    result = parser.parse(txt)
    result.to_a.should == [:foo, 'foo', []]
  end
    
  it "should name literals without name identically to their 
      constant contents if a string" do
    parser = Neotoma::Parser.new do
      lit('foo')
    end
    txt    = 'foo'
    result = parser.parse(txt)
    result.to_a.should == [:foo, 'foo', []]
  end  
  
  it "should be able to parse a sequence of words" do
    parser = Neotoma::Parser.new do
      lit('foo', :foo) & lit('bar', :bar) & lit('baz', :baz) 
    end
    txt    = 'foobarbaz'
    result = parser.parse(txt) 
    result.should_not be_nil
    expected =  [:"{{foo|bar}|baz}", nil, [[:"{foo|bar}", nil, [[:foo, "foo", []], [:bar, "bar", []]]], [:baz, "baz", []]]]
    result.to_a.should == expected
  end
  
  it "should be able to parse a alternates" do
    parser = Neotoma::Parser.new do
      lit('foo', :foo) / lit('bar', :bar)
    end
    txt1   = 'foo'
    txt2   = 'bar'
    result = parser.parse(txt1)
    result.should_not be_nil
    result.to_a.should == [:foo, 'foo', []]
    result = parser.parse(txt2)
    result.should_not be_nil
    result.to_a.should == [:bar, 'bar', []]
  end
  
  it "should fail to parse if the sequence is not correct" do
    parser = Neotoma::Parser.new do
      lit('foo') & lit('bar') & lit('baz') 
    end
    txt    = 'foobarbar'
    result = parser.parse(txt)
    result.should be_nil
  end

  it "should be able to parse using regular expressions" do
    parser = Neotoma::Parser.new do
      lit('\w+', :whitespace)  
    end
    txt    = 'foobarbaz'
    result = parser.parse(txt)
    result.should_not be_nil
    result.to_a.should == [:whitespace, 'foobarbaz', []]
  end
  
  it "should be able to fail parsing using regular expressions" do
    parser = Neotoma::Parser.new do
      lit('\w+')  
    end
    txt    = ' foobarbaz '
    result = parser.parse(txt)
    result.should be_nil
  end
  
  it "should support .* for repetition" do
    parser = Neotoma::Parser.new do
      self.foo        = /foo/
      self.manyfoo    = self.foo.*
      self.start  = self.manyfoo
    end
    txt    = 'foofoo'
    result = parser.parse(txt)
    result.should_not be_nil
    sub    = [:foo, 'foo', []]
    result.to_a.should == [:"foo*", nil, [sub, sub]]
  end
  
  it "should support .any? for repetition" do
    parser = Neotoma::Parser.new do
      self.foo        = /foo/
      self.manyfoo    = self.foo.any?
      self.start  = self.manyfoo  
    end
    txt    = 'foobarbaz'
    result = parser.parse(txt)
    result.should_not be_nil
    result.to_a.should == [:foo?, nil, [[:foo, "foo", []]]]
  end
  
  
  it "should support .* with an empty string" do
    parser = Neotoma::Parser.new do
      lit('\w', :char).*  
    end
    txt    = ''
    result = parser.parse(txt)
    result.should_not be_nil
    result.to_a.should ==  [:"char*", nil, []]
  end
  
  it "should support .+ for repetition" do
    parser = Neotoma::Parser.new do
      lit('foo').+  
    end
    txt    = 'foofoo'
    result = parser.parse(txt)
    result.should_not be_nil
    ok = [:"foo+", nil, [[:foo, "foo", []], [:foo, "foo", []]]]
    result.to_a.should == ok 
  end
  
  it "should be able to parse keywords correctly" do
    parser = Neotoma::Parser.new do
      keyword('do')
    end
    txt    = 'do '
    result = parser.parse(txt)
    result.should_not be_nil    
    result.to_a.should == [:do, "do", []]
    txtbad = 'dodo'
    result = parser.parse(txtbad)
    result.should be_nil
  end
  
  it "should parse compicated grammars with recursive structures" do
    s = %q{do foo end}
  
    parser       = Neotoma::Parser.new do  
      self.program    = (self.doblock / self.white_word).*
      self.program.name = :program
      self.whitespace = '\W+'
      self.word       = '\w+'
      self.key_do     = keyword('do')
      self.key_end    = keyword('end')
      # self.brace_open = '{'
      # self.brace_close= '}'
      self.white_word   = word / whitespace
      self.inblock      = (self.doblock / self.white_word).*
      self.inblock.name = 'inblock'
      self.doblock      = self.key_do & self.inblock & self.key_end
      self.doblock.name = 'doblock'
      # self.braceblock = brace_open & inblock & brace_close
      # self.block      = doblock / braceblock 
      self.start        = self.program
    end
  
    results           = parser.parse(s)
    p results.to_a
    results.should_not be_nil
    # results.to_graph.display
    # p results
    
  end

  
  
end





