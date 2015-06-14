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
  server = TCPServer.new 1111
  loop {
    client = server.accept
    line = client.gets
    puts line
    if line == "SAVE" 
       File.open('shipping_label.jpeg', 'wb') do|f|
          f.write(Base64.decode64(line))
       end
       client puts "SAVEDONE"
    else
        str = ""
        begin
          res  = @conn.exec( line )
          puts res.res_status(res.result_status)
        rescue PG::Error => err
          str = err.result.error_field( PG::Result::PG_DIAG_SEVERITY )
          puts "Return error!"
        end
      if str == "ERROR" # has error
        puts str
        client.puts "ERROR"
        next
else # no error
  puts "NO ERROR!"
        client.puts "NOERROR"
        resultstatus = res.res_status(res.result_status)
        if resultstatus == "PGRES_COMMAND_OK"
          puts "no return data"
          client.puts "no return data"
          client.close
          next
        elsif resultstatus == "PGRES_TUPLES_OK"
          client.puts "has return data"
        else
          puts "Impossible! QUIT!"
          client.puts "ERROR2"
          next
        end 
        fieldArray=res.fields()
        #fieldArray.each do |elem|
        #print "elem="+elem+"\n"
        #end
        #puts "Number of fields: ",fieldArray.count
        h = Hash.new  
        for i in 0..fieldArray.count-1
          a = []
          res.each do |row|
          a.push(row[fieldArray[i]].lstrip.rstrip)
          end         
        end
        h[fieldArray[i]] = a
        json1 = h.to_json
        client.write(json1)
        client.close    
end
    end
  }
  server.close
end

main
