$LOAD_PATH.unshift File.join( File.dirname(__FILE__), '..', 'lib' )
require 'rubygems'
require 'rgdb'
require 'net/ssh/telnet'

s = Net::SSH::Telnet.new(
        #~ "Dump_log" => "/dev/stdout",
        "Host" => "192.200.41.21",
        "Username" => "root",
        "Password" => "sangfor"
)

gdb = Rgdb.new(s)

puts gdb.attach(24985)
puts gdb.c!
gdb.ctrl_c
puts gdb.w
puts "close..."
gdb.close