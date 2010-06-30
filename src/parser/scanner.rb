require 'strscan'

# The scanner wraps the input string
# and also provides a cache for previously scanned results 
class Scanner < StringScanner
  attr_reader :checkpoints
  
    def initialize(string)
      super(string)
      @checkpoints = [] # Stack of checkpoints
    end
   
    # Commits the current position as a checkpoint. Returns self.
    def checkpoint()
      @checkpoints << self.pos
      return self
    end
       
    # Rolls back to the previous checkpoint. returns self. 
    # Rolls back to position 0 if the checkpoint stack is empty. 
    def rollback()
      oldpos    = @checkpoints.pop
      unless oldpos
        oldpos = 0
      end
      self.pos  = oldpos
      return self    
    end
    
    alias old_scan scan
    
    # Scans for the regular expression pattern, but rolls back in case
    # no result is found. 
    # Returns the result of the scan, or nil if the scan failed. 
    def scan(pattern)
      self.checkpoint()
      result      = self.old_scan(pattern)
      return result if result
      self.rollback()
      return result
    end 
    
    # Returns the rest of the scanner
    def rest
      return self.string[self.pos..(self.string.size)]      
    end
   
end 
