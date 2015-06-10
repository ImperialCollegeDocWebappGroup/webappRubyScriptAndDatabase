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
  #line = "UPDATE cities SET location = '(2,2)' WHERE name = 'Sam'";
  #line = "SELECT usrname,(unnest(shows)).content,(unnest(shows)).publishtime AS ptime FROM publishs WHERE usrname in (SELECT unnest(friends) FROM friendlist WHERE uname = 'nathan') ORDER BY ptime DESC LIMIT 20;"
  server = TCPServer.new 1111 # Server bind to port 1111
  loop {        # Servers run forever
    # Thread.start(server.accept) do |client|
    client = server.accept    # Wait for a client to connect
    line = client.gets
    puts line
    if line == "SAVE" 
       File.open('shipping_label.jpeg', 'wb') do|f|
          f.write(Base64.decode64(line))
       end
       client puts "SAVEDONE"
    else 
      #File.open('shipping_label.jpeg', 'wb') do|f|
      #f.write(Base64.decode64(line))
      #end
      #client.puts "Sent from server"
      str = ""
      begin
        res  = @conn.exec( line )
        puts res.res_status(res.result_status)
        #PGRES_EMPTY_QUERY #PGRES_COMMAND_OK #PGRES_TUPLES_OK #PGRES_COPY_OUT #PGRES_COPY_IN #PGRES_BAD_RESPONSE #PGRES_NONFATAL_ERROR#PGRES_FATAL_ERROR#PGRES_COPY_BOTH
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
        h[fieldArray[i]] = a
        #pp h #to create a JSON string
        json1 = h.to_json
        #obj = JSON.parse(json1)
        #pp obj
        client.write(json1)
        client.close
      end
    end
  }  
  server.close
end

main
  #puts "======\n"
    #res.each do |row|
    #puts "name="+row[fieldArray[0]]  +" location="+row[fieldArray[1]]
    #end
    #puts "======\n"
    # puts res.to_json
    #res.each do |row|
    #  row.each do |column|
    #    puts column
    #  end
    #end
    #puts  ' string '.lstrip.chop.length
