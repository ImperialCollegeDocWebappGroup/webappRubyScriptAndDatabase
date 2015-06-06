require 'pg'
require 'socket'
require 'json'
require 'pp'

def main
	@conn = PGconn.connect(
		:host => 'db.doc.ic.ac.uk',
		:port => '5432',
       		:dbname => 'g1427141_u',
        	:user => 'g1427141_u',
        	:password => 'BhNt16JkU5')
    	status = @conn.connect_poll
    	if status == PG::PGRES_POLLING_OK
		print "connect success!\n"
    	else
    abort("connect fail!")
	end

  # line = "UPDATE cities SET location = '(2,2)' WHERE name = 'Sam'";
line = " SELECT * FROM cities;"
  begin
    res  = @conn.exec( line )
       puts res.res_status(res.result_status)
    #PGRES_EMPTY_QUERY
    #PGRES_COMMAND_OK
   # PGRES_TUPLES_OK
   # PGRES_COPY_OUT
  #  PGRES_COPY_IN
   # PGRES_BAD_RESPONSE
   # PGRES_NONFATAL_ERROR
    #PGRES_FATAL_ERROR
   #PGRES_COPY_BOTH
str = ""
  rescue PG::Error => err
     str = err.result.error_field( PG::Result::PG_DIAG_SEVERITY )
    puts " error!"
  end
 if str == "ERROR"
  # has error
   puts str
else
  # no error
  resultstatus = res.res_status(res.result_status)
  if resultstatus == "PGRES_COMMAND_OK"
    puts "no return data"
  elsif resultstatus == "PGRES_TUPLES_OK"
    puts "has return data"
  else
    puts "fucked!"
  end
  fieldArray=res.fields()
fieldArray.each do |elem|
    print "elem="+elem+"\n"
end
puts fieldArray.count
h = Hash.new
    for i in 0..fieldArray.count-1
       a = []
        res.each{ |row|
          a.push(row[fieldArray[i]])
            
        } 
h[fieldArray[i]] = a
  end
 json1 = h.to_json
#obj = JSON.parse(json1)
pp json1
server = TCPServer.new 1111 # Server bind to port 1111
  client = server.accept    # Wait for a client to connect
  line = client.gets
  puts line
    client.puts json1
client.close
server.close

end
end

main