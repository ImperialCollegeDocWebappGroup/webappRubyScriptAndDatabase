require 'pg'
require 'socket'

def main
	@conn = PGconn.connect(
		:host => 'db.doc.ic.ac.uk',
		:port => '5432',
       		:dbname => 'g1427141_u',
        	:user => 'g1427141_u',
        	:password => 'BhNt16JkU5')
    	status = @conn.connect_poll
    	if status == PG::PGRES_POLLING_OK
		print "connected !\n"
    	else
		print "not ok!"
	end

   	#res  = @conn.exec( "SELECT * FROM cities;" )
	#res.each do |row|
 	# 	row.each do |column|
   	#		puts column
  	#	end
	#end

puts "waiting for connection"
server = TCPServer.new 1111 # Server bind to port 1111

#for i in 0..3

  client = server.accept    # Wait for a client to connect

  
  line = client.gets
  puts line
  
  begin
    res  = @conn.exec( line )
    #  client.puts "Hello !"
  #client.puts "Time is #{Time.now}"
str = ""
  rescue PG::Error => err
     str = err.result.error_field( PG::Result::PG_DIAG_SEVERITY )
    puts "checking error"
  end
 if str == "ERROR"
client.puts str
else
res.each do |row|
 	 	row.each do |column|
			puts column
   			client.puts column
  		end
	end
end
  #print res.to_json
	

  client.close
#end
server.close

end

main
