#~ require 'net/ssh/telnet'
class Rgdb
  class Shell
    def initialize
      @data = nil
    end
    
    def puts
    end
    
    def print
    end
    
    def waitfor(options)
      yield @data if block_given?
    end
  end
end
