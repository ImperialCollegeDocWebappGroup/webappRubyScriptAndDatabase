require 'pg'
require 'socket'
require 'json'
require 'base64'
require 'pp'
require 'date'

def main
  localIp = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
  puts localIp
  filePath = "/homes/jl6613/public_html/"
  fileName = "serverIp.txt"
  File.open(filePath+fileName, 'w') { |file| file.write(localIp) }
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
   #SELECT EXISTS(SELECT 1 from userprofile WHERE login = 'Sam');
  #line2 = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = 'Sam2');"
  #UPDATE publishs SET shows = array_append(shows, ROW('http://www.selfridges.com/en/givenchy-amerika-cuban-fit-cotton-jersey-t-shirt_242-3000831-15S73176511/?previewAttribute=Black', LOCALTIMESTAMP,ARRAY[]::comment[],'')::publishitem) WHERE usrname = 'nathan';
  line2 = query = "UPDATE publishs SET shows = array_append(shows, ROW('http://www.selfridges.com/en/givenchy-amerika-cuban-fit-cotton-jersey-t-shirt_242-3000831-15S73176511/?previewAttribute=Black', LOCALTIMESTAMP,ARRAY[]::comment[],'')::publishitem) WHERE usrname = 'nathan';"
    #puts res[0]["exists"]
    begin
          res  = @conn.exec( line2 )
          puts res.res_status(res.result_status)
        rescue PG::Error => err
          str = err.result.error_field( PG::Result::PG_DIAG_SEVERITY )
          puts "Return error!"
        end
    

  abort("test end")
  server = TCPServer.new 1111
  loop {
    client = server.accept
    line = client.gets
    puts line
    if line == "SAVE\n" 
       puts "yes"
       line = client.gets
       File.open('shipping_label.jpeg', 'wb') do|f|
          f.write(Base64.decode64(line))
       end
       client.puts "SAVEDONE"
       client.close
       puts "save done, close"
    else
      puts "NO"
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
                  sleep(1.0)
        resultstatus = res.res_status(res.result_status)
        if resultstatus == "PGRES_COMMAND_OK"
          puts "no return data"
          client.puts "no return data"
          client.close
          next
        elsif resultstatus == "PGRES_TUPLES_OK"
          puts " return data"
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
                  sleep(1.0)
        puts "data..."
        client.write(json1)
        client.close    
end
    end
  }
  server.close
end

main