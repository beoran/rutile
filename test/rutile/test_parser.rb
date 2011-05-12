require 'test_helper'



require 'rutile'
require 'parslet'
require 'parslet/convenience'

assert { Rutile::Parser }
 
assert { Rutile::Parser.new }

def parse(rule, text)
  parser = Rutile::Parser.new
  rule   = parser.send(rule.to_sym)
  return rule.parse_with_debug(text)
  rescue $! 
  p $!
  puts $!.backtrace.join("\n")
  return nil 
end

def noparse(rule, text)
  parser = Rutile::Parser.new
  rule   = parser.send(rule.to_sym)
  rule.parse(text)
  return false
  rescue $! 
  # p $!
  return true 
end

res = nil

# Escaped end of lines, and line endings
assert { parse :esceol, %{\\\n}                         }
assert { parse :esceol, %{\\  \n}                       }
assert { parse :blanks, %{ \t }                         }
assert { parse :ws    , %{ \t }                         }
assert { parse :ws    , %{\\\n}                         }
assert { parse :ws    , %{   \\\n   }                   }
assert { parse :ws    , %{   \\  \n   }                 }
assert { parse :ws    , %{   \\  \n   }                 }
assert { noparse :eol , %{\\\n}                         }
# comments
assert { parse :comment , %{#hello\n}                   }

# commas
assert { parse :comma , ",   \n   "                     }
assert { parse :comma , ",   \n"                        }
assert { parse :comma , ",   "                          }
assert { parse :comma , ","                             }


assert { parse :constant_name, 'HELLO'                  }
assert { noparse :constant_name, 'HeLLO'                }
assert { parse :eol, "\n"                               }
assert { parse :eol, "\r"                               }
assert { parse :eol, "\r\n"                             }
assert { parse :eol, ";"                                }
assert { noparse :eol, "\n\r"                           }
assert { noparse :eol, "  "                             }
assert { noparse :eol, "\\\n"                           }
assert { noparse :eol, "  \\  \n"                       }

assert { parse :ws, "\\\n"                              }

assert { parse :float,   '120000.012345678e-10'         }
assert { parse :integer, '120000'                       }
assert { parse :string, '"foo"'                         }
assert { parse :literal, '120000.012345678e-10'         }

assert { parse :type, 'Int@@'                                   }

assert { parse :kw_end, %{end}                                  }
assert { noparse :kw_end, %{endfoo}                             }
assert { parse   :identifier, %{endfoo}                         }
# the following is subtle, keywords should not gobble up trailing spaces.
assert { noparse :kw_end, %{end }                               }
assert { parse   :end_bug   , %{endfoo}                         }
assert { noparse       :kw_end, %{ending}                       }

assert { parse :require_action, %{   require "foo" \n}          }
assert { parse :private_action, %{private\n}                    }
assert { parse :private_action, %{  private\n}                  }
assert { parse :private_action, %{  private  \n}                }
assert { parse :public_action , %{public\n }                    }
assert { parse :public_action , %{  public\n }                  }
assert { parse :private_action, %{  private  \n}                }
assert { parse :compiler_action, %{ require "foo" \n}            }
assert { parse :compiler_action, %{  private     \n }            }
assert { parse :compiler_action, %{  public      \n }            }
assert { parse :unit, %{ require "foo" \n}            }
assert { parse :unit, %{  private     \n }            }
assert { parse :unit, %{  public      \n }            }

assert { parse :constant_set  , %{ FOO = "foo"     \n}          }
assert { parse :constant_set  , %{ Int FOO = "foo"     \n}      }
assert { parse :constant_set  , %{ Int@@@ FOO = "foo"     \n}   }



assert { parse :assign        , '=   '                          }
assert { parse :literal, '"foo"  '                              }

assert { parse :eat_line_end , %{\n}                            }
assert { parse :eat_line_end , %{  \n}                          }
assert { parse :eat_line_end , %{  \n  }                        }
assert { parse :empty_line   , %{  \n  }                        }
assert { parse :empty_lines  , %{  \n \n \n  }                  }

assert { parse :type_name    , 'Int' }
assert { parse :member_name  , '@foo'}
assert { noparse :type_name  , 'F'   }
assert { noparse :type_name  , 'FOO' }
assert { parse   :constant_name  , 'F'   }
assert { parse   :constant_name  , 'FOO' }
assert { parse   :identifier     , 'foo' }

# function declarations
assert { parse   :argument       , 'foo' }
assert { parse   :argument_list  , 'foo , bar , baz' }
assert { parse   :argument_list  , 'foo,bar,baz' }
assert { parse   :argument_list  , '(foo,bar,quux)'  }
assert { parse   :argument_list  , '(foo,bar,quux)'  }
assert { parse   :argument       , 'Int foo' }
assert { parse   :argument_list  , 'Int foo , Char bar , Zip baz' }
assert { parse   :argument_list  , '(Int foo , Char bar , baz)' }



assert { res = parse   :extern_function, %{extern def foo
} }
assert { res = parse   :extern_function, %{extern def Int foo;} }
assert { noparse   :extern_function, %{externdef Int foo;} }
assert { res = parse   :extern_function, %{extern def Int foo bar,baz , quux  
} }
assert { res = parse   :extern_function, %{extern def Int foo Int bar,baz , quux
} }


assert { res = parse   :function_body, %{
} }


assert { res = parse   :define_function, %{def foo
end   
} }

assert { res = parse   :define_function, %{def Int foo
end   
} }

assert { res = parse   :define_function, %{def Int foo Int bar, quux

end
} }


assert { parse :primary_expression, "a" }
assert { parse :unary_expression, "a" }
assert { parse :multiplicative_expression, "a*b" }

# assert { parse :additive_expression, "a" }
# assert { parse :additive_expression, "a+b" }
# 
# assert { res = parse   :expression, "a+b"}

# p res
 


# assert { res = parse(:unit, DATA.read) }


__END__
 
 
THIS_IS_A_CONSTANT = "Hello"

extern def Int foo
extern def Char@ foo

 
 
 

