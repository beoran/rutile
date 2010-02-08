require 'tempfile'
require 'sexp_processor'
require 'ruby_parser'



class Ruby2Rutile < SexpProcessor
  def rewrite_iter(expr)
    subexpr = expr[1]
    return expr unless subexpr
    call    = subexpr[0]
    return expr unless call == :call
    kind    = subexpr[2]
    args    = subexpr[3]
    p "----"
    if [:primitive, :inline, :record, :func].member? kind
      p args
      result = Sexp.new(kind, args, *expr[3..expr.size])
      p result
      return result
    end
    return expr
  end
  
  def rewrite_call(expr)
    called  = expr[2]
    if [:asm].member? called
      result = Sexp.new(called, *expr[3..expr.size])
      return result
    end
    return expr
  end

end


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
    @rewrite= Ruby2Rutile.new
    
    @rewrite.rewrite(res)
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

