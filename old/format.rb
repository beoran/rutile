# Format encapsulates the output format of an assembler or linker. 

class Format
  # autoload sub formats
  autoload :Bin, 'format/bin'

  # The output buffer
  attr_reader   :buffer
  # Endianness of the output
  attr_accessor :endian
  
  def initialize
    @buffer = ""
    @buffer.force_encoding('ASCII-8BIT')
    # Turn the buffer into a byte byffer
    @pos    = @buffer.bytesize
    @endian = :little
    # Little endndian by default.    
  end
    
  # Adds the string to the format's output buffer as a stream of bytes.
  # Returns the new position index, and the old position index.
  # Non-binary formats should overwrite this method, as all other methods
  # that add to the buffer should call this one   
  def string(str)
    old     = @pos
    @buffer << str.force_encoding('ASCII-8BIT')
    @pos    = @buffer.bytesize
    return @pos, old
  end
  
  # Returns true if we're in little endian format, false if not.
  def little_endian?
    return @endian == :little
  end
  
  # Adss a zero terminated string of ascii characters.
  # Returns the new position index, and the old position index.
  def asciiz(str)
    aid = [str].pack('Z*')
    return string(aid)
  end
  
  # Adds the given bytes (unsigned chars) to this format's buffer
  # Bytes should be an (array of) number, not a string
  # Returns the new position index, and the old position index  
  def byte(*bytes)
    return string(bytes.pack('C*'))  
  end
  
  # Adds the given short integers (int16) to this format's buffer.
  # The endianness is controlled by setting .endian to :little or :big 
  # Shorts should be an (array of) number, not a string.
  # Returns the new position index, and the old position index  
  def short(*shorts)
    format = ( little_endian? ? 'v*' : 'n*') 
    return string(shorts.pack(format))  
  end
  
  # Adds the given 32 bits integers (int32) to this format's buffer.
  # The endianness is controlled by setting .endian to :little or :big 
  # Ints should be an (array of) number, not a string.
  # Returns the new position index, and the old position index  
  def int(*ints)
    format = ( little_endian? ? 'V*' : 'N*') 
    return string(ints.pack(format))
  end
  
  # Adds the given 64 bits integers (int64) to this format's buffer.
  # The endianness is controlled by setting .endian to :little or :big 
  # Ints should be an (array of) number, not a string.
  # Returns the new position index, and the old position index  
  def quad(*ints)
    raise "Quad does not work for big endian formats yet!" unless little_endian?
    format = ( little_endian? ? 'Q*' : 'q*')
    # XXX: does not work for big endian!!! 
    return string(ints.pack(format))
  end
  
  
  # Adds the given single precision float (float32) to this format's buffer.   
  # The endianness is controlled by setting .endian to :little or :big 
  # Singles should be an (array of) number, not a string.
  # Returns the new position index, and the old position index
  def single(*singles)
    format = ( little_endian? ? 'e*' : 'g*')
    return string(singles.pack(format))
  end
  
  # Adds he given double precision float (float32) to this format's buffer.
  # The endianness is controlled by setting .endian to :little or :big 
  # Floats should be an (array of) number, not a string.
  # Returns the new position index, and the old position index
  def float(*floats)
    format = ( little_endian? ? 'E*' : 'G*')
    return string(singles.pack(format))
  end
    
  # Writes the contents of the buffer to the object f using write
  # returns the results fo write.  
  def write_to_file(f)
    return f.write(self.buffer)
  end
  
  # Opens the file named by filename for writing, destrying it if it existed, 
  # and overwrites it with the contents of the buffer.
  # Returns the amount of bytes written.
  def overwrite(filename)
    res = -1
    File.open(filename, 'w+') do | file | 
      p file 
      res = write_to_file(file)    
    end 
    return res
  end 
  
 
  
  
end

if __FILE__ == $0

  format = Format.new()  
  format.asciiz("hello")
  p format.buffer
  format.overwrite('/tmp/out.bin')



end
