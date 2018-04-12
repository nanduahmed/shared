#!/usr/bin/ruby -w

puts "Hello"

print <<St
 this is privateis is
dwd
St

class Vehicle
    _val = 0
    @num = 10
    @@global = 100
end

begin
    puts "Raising"
    raise "Nothing"
    
    rescue Exception => e
    puts "I am rescued"
    puts e.message

end

print <<`Com`
ls -la
dir
Com

v1 = Vehicle. new
v2 = Vehicle. new

a = defined? v1

puts a
puts v1
puts v2

BEGIN {
    puts "Init"
   
}

def aBlock
    puts "aBlock Start"
    yield
    yield

end

aBlock { puts "In Block" }


END {
    puts "Terminating Ruby Program"
 
}


