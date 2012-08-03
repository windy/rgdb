require 'spec_helper'
describe Rgdb do
  it "should get version" do
    lambda { Rgdb::VERSION }.should_not raise_error
  end
  describe "attach" do
    require 'rgdb/shell'
    before(:all) do
      @shell = Rgdb::Shell.new
      @rgdb = Rgdb.new(@shell)
      
      @msg = {
      
      :attach_success => %{
GNU gdb (GDB) Red Hat Enterprise Linux (7.2-56.el6)
Copyright (C) 2010 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Attaching to process 8620
Reading symbols from /root/test...done.
Reading symbols from /lib64/libc.so.6...(no debugging symbols found)...done.
Loaded symbols for /lib64/libc.so.6
Reading symbols from /lib64/ld-linux-x86-64.so.2...(no debugging symbols found)...done.
Loaded symbols for /lib64/ld-linux-x86-64.so.2
0x0000003edf8a6a50 in __nanosleep_nocancel () from /lib64/libc.so.6
Missing separate debuginfos, use: debuginfo-install glibc-2.12-1.7.el6_0.5.x86_64
(gdb) 
      },
      
      :attach_fail => %{
GNU gdb (GDB) Red Hat Enterprise Linux (7.2-56.el6)
Copyright (C) 2010 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Attaching to process 86201
ptrace: No such process.
(gdb)}
      }
      
      
    end
    it "should can attach a process" do
      @shell.should_receive(:puts).with("gdb --pid 1").and_return(true)
      @shell.should_receive(:waitfor).and_yield(@msg[:attach_success]).and_return(true)
      @rgdb.attach(1)
    end
    
    it "should raise error when cannot attach a process" do
      @shell.should_receive(:puts).with("gdb --pid 1").and_return(true)
      @shell.should_receive(:waitfor).and_yield(@msg[:attach_fail]).and_return(true)
      lambda { @rgdb.attach(1) }.should raise_error
    end
  end
  
  describe "cmd" do
    require 'rgdb/shell'
    before(:all) do
      @shell = Rgdb::Shell.new
      @rgdb = Rgdb.new(@shell)
    end
    
    it "break ok" do
      break_msg = %{
Breakpoint 1 at 0x40055b: file test.c, line 13.
    }
      @rgdb.should_receive(:cmd_waitfor).and_return(break_msg)
      lambda { @rgdb.b("init") }.should_not raise_error
    end
    
    it "break error" do
      break_msg = %{
Function "abc" not defined.
Make breakpoint pending on future shared library load? (y or [n])
    }
      @rgdb.stub(:cmd_waitfor).and_return(break_msg)
      lambda { @rgdb.b("init") }.should raise_error
    end
    
    it "n,p,s" do
      @rgdb.stub(:cmd).and_return(true)
      lambda { @rgdb.n }.should_not raise_error
      lambda { @rgdb.p('a') }.should_not raise_error
      lambda { @rgdb.s }.should_not raise_error
    end
  end
  
end