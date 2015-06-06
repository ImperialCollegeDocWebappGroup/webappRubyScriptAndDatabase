require 'socket'

s = TCPSocket.new '146.169.52.13', 1111

 #line = s.gets # Read lines from socket
 # puts line         # and print them
  
#line = s.gets # Read lines from socket
 # puts line         # and print them
  
#line = "SELECT * FROM citie;"
line = "Hello from client!\n"
s.puts line

#while line = s.gets
line2 = s.gets
	puts line2
#end




#s.write 'client says hello'

s.close             # close socket when done
