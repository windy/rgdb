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

puts gdb.attach(5238)
gdb.b('init')
gdb.c
puts gdb.p('p.a')
gdb.cmd('d 1')
gdb.c!
#~ gdb.close