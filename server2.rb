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
  server = TCPServer.new 1111
  index = 0
  loop {
    client = server.accept
    puts "client accpetd"
    line = client.gets
    puts line
    if (line == "SAVE1\n") || (line == "SAVE2\n")
      cloth = ""
      if line == "SAVE1\n"
        cloth = "tops"
      else
        cloth = "buttoms"
      end
      puts "save confirm"
      client.puts "GOOD"
      line = client.gets
      #SELECT EXISTS(SELECT 1 from userprofile WHERE login = 'Sam');
      #line2 = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = 'Sam2');"
      #puts res[0]["exists"]
      checkExist = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = '" + line + "');"
      res  = @conn.exec(checkExist)
      result = res[0]["exists"]
      if result == "t"
        fileName = filePath + "file" + index.to_s + ".jpeg"
        line = client.gets
        File.open(fileName, 'wb') do|f|
          f.write(Base64.decode64(line))
        end
        query = "UPDATE userprofile SET " + cloth + " = array_append(" + cloth +", " + index.to_s + ") WHERE login = '';"
        begin
          res  = @conn.exec(query)
          puts res.res_status(res.result_status)
        rescue PG::Error => err
          str = err.result.error_field( PG::Result::PG_DIAG_SEVERITY )
          puts "Return error!"
        end
        if str == "ERROR"
          puts str
          client.puts "ERROR"
          next
        end 
        index += 1
        client.puts "SAVEDONE"
        client.close
        puts "save done, close"
      else
        puts "save username error"
        client.puts "ERROR"
        client.close
        next
      end
    elsif line == "PUBLISH\n"
      #time = Time.now.to_s
      #SELECT CURRENT_TIMESTAMP(2);
      puts "publish confirm"
      client.puts "GOOD"
      line = client.gets
      checkExist = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = '" + line + "');"
      uname = line
      res  = @conn.exec(checkExist)
      result2 = res[0]["exists"]
      if result2 == "t"
        client.puts "GOOD"
        line = client.gets
        query = "UPDATE publishs SET shows = array_append(shows, ROW('"+ line+"', LOCALTIMESTAMP,ARRAY[]::comment[],'')::publishitem) WHERE usrname = '"+uname+"';"
        begin
          res  = @conn.exec(query)
          puts res.res_status(res.result_status)
        rescue PG::Error => err
          str = err.result.error_field( PG::Result::PG_DIAG_SEVERITY )
          puts "Return error!"
        end
        if str == "ERROR"
          puts str
          client.puts "ERROR"
          next
        end 
        client.puts "PUBLISHDONE"
        client.close
        puts "save done, close"
      else
        puts "save username error"
        client.puts "ERROR"
        client.close
        next
      end
    else
      puts "JUST QUERY"
      query = line
      str = ""
      begin
        res  = @conn.exec(query)
        puts res.res_status(res.result_status)
      rescue PG::Error => err
        str = err.result.error_field( PG::Result::PG_DIAG_SEVERITY )
        puts "Return error!"
      end
      if str == "ERROR" # has error
        puts str
        client.puts "ERROR"
        next
      else
        puts "NO ERROR!"
        client.puts "NOERROR"
        reply = client.gets
        puts reply
        resultstatus = res.res_status(res.result_status)
        if resultstatus == "PGRES_COMMAND_OK"
          puts "no return data"
          client.puts "NOR"
          client.close
          next
        elsif resultstatus == "PGRES_TUPLES_OK"
          puts "has return data"
          client.puts "YESR"
        else
          puts "Impossible! QUIT!"
          client.puts "ERROR2"
          next
        end 
        fieldArray=res.fields()
        h = Hash.new  
        for i in 0..fieldArray.count-1
          a = []
          res.each do |row|
          a.push(row[fieldArray[i]].lstrip.rstrip)
          end         
        end
        h[fieldArray[i]] = a
        json1 = h.to_json
        puts "waiting"
        reply = client.gets
        puts reply
        puts "data..."
        client.write(json1)
        client.close
        puts "closed"    
      end
    end
  }
  server.close
end

main
