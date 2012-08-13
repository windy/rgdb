# coding : utf-8
require 'timeout'

class Rgdb
  
  class Error < RuntimeError; end
  class AttachError < Error; end
  class ContinueTimeoutError < Error; end
  class PrintError < Error; end
  def initialize(shell)
    @shell = shell
    # 延迟执行的标记
    @running = false
  end
  attr_reader :shell
  def attach(pid)
    cmd = "gdb --pid #{pid}"
    ret = cmd(cmd)
    if ret.include?("No such process")
      raise AttachError,"no such proces: #{pid}"
    elsif ret.include?("Operation not permitted")
      raise AttachError, "operation not permitted(maybe another gdb process has attached it): #{pid}"
    end
    ret
  end
  
  def start(file)
    cmd = "gdb #{file}"
    cmd(cmd)
  end
  # break
  def break(what)
    cmd = "b #{what}"
    ret = cmd_waitfor(cmd, /\(gdb\)|Make breakpoint pending on future shared library load/)
    case ret
    when /not defined/
      if ret.include?("Make breakpoint pending on future shared library load")
        cmd('n')
      end
      raise BreakPointError, "function not defined: #{what}"
    when /No line/
      raise BreakPointError, "No line here"
    end
    ret
  end
  # continue
  def continue(options = {})
    timeout = options[:timeout] || 3
    ret = ""
    begin
      timeout(timeout) do
        ret = cmd('c')
      end
    rescue TimeoutError
      #TODO: stop it
      raise ContinueTimeoutError, "timeout after #{timeout} sencods"
    end
    ret
  end
  
  # continue no wait
  def continue!
    cmd_waitfor('c','Continuing.')
  end
  
  # wait for a cmd over, e.g. c!
  def wait(options = {})
    timeout = options[:timeout] || 3
    ret = ""
    begin
      timeout(timeout) do
        ret = waitfor(/\(gdb\)/)
      end
    rescue TimeoutError
      #TODO: stop it
      raise ContinueTimeoutError, "timeout after #{timeout} seconds"
    end
    ret
  end
  
  # print
  def print(what)
    ret = cmd("p #{what}")
    case ret
    when /No symbol/
      raise PrintError, "no symbol print here"
    when /syntax error/
      raise PrintError, "syntax error"
    end
    ret
  end
  # next
  def next
    cmd('n')
  end
  # step
  def step
    cmd('s')
  end
  # TODO: 重新执行的提示, 以及
  def run
    cmd('r')
  end
  
  def ctrl_c
    shell.print("\x03")
  end
  
  alias_method :b, :break
  alias_method :c, :continue
  alias_method :c!, :continue!
  alias_method :p, :print
  alias_method :n, :next
  alias_method :s, :step
  alias_method :r, :run
  alias_method :w, :wait
  
  def cmd(what)
    cmd_waitfor(what, /\(gdb\)/)
  end
  
  # 等
  def waitfor(msg)
    msg = Regexp.new(msg) if msg.kind_of?(String)
    output = ""
    shell.waitfor(msg) do |data|
      output = data
    end
    output.gsub(/\(gdb\)\s*$/,'').strip
  end
  
  
  def cmd_waitfor(cmd, msg)
    #~ puts "execute: #{cmd}"
    shell.puts(cmd)
    waitfor(msg).gsub(/^\s*#{cmd}/,'')
  end
  
  def close
    ret = cmd_waitfor('q', /[$%#>] \z|Quit anyway/n)
    #~ puts ret
    if ret.include?("Quit anyway")
      cmd_waitfor('y', /[$%#>] \z/n)
    end
  end
  
end
