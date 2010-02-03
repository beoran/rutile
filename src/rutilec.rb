require 'tempfile'


class Compiler

















  def assemble(asmfile, objfile)
  end

  def link(outname, objfile)
  end

  def compile(inname, outname)
    infile  = file.open(inname, "rt");
    asmfile = Tempfile.new('rtasm')
    objfile = Tempfile.new('rtobj')
    outfile = file.open(outname, "wb+");    
    assemble(asmfile, objfile)
    link(outname, objfile)
  end
  
  def execute(inname, outname)
    compile(inname, outname)
  end

end



if __FILE__ == $0
  
  c = Compiler.new
  c.compile('../spec/test1.rt', '../spec/test1')
  
end  

