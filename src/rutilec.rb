require 'tempfile'
require 'ruby_parser'





class Compiler

  def assemble(asmfile, objfile)
  end

  def link(outname, objfile)
  end
  
  def compile(infile)
    @parser = RubyParser.new
    text    = infile.read
    infile.close    
    res = @parser.parse(text)
  end

  def compile_program(inname, outname)
    infile  = File.open(inname, "rt");
    asmfile = Tempfile.new('rtasm')
    objfile = Tempfile.new('rtobj')
    outfile = File.open(outname, "wb+");
    tree    = compile(infile)
    p tree    
    assemble(asmfile, objfile)
    link(outname, objfile)
  end
  
  def execute(inname, outname)
    compile(inname, outname)
  end

end



if __FILE__ == $0
  
  c = Compiler.new
  c.compile_program('../spec/test1.rt', '../spec/test1')
  
end  

