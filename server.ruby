require 'pg'
require 'socket'
require 'json'
require 'base64'
require 'pp'
require 'date'

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
  index = 0
  filePath = ""
  loop {
    client = server.accept
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
      checkExist = "select exists(select 1 from userprofile where login = " + line + ");
      res  = @conn.exec(checkExist)
      if res == "true"
        fileName = filePath + "file" + index.to_s + ".jpeg"
        line = client.gets
        File.open(fileName, 'wb') do|f|
          f.write(Base64.decode64(line))
        end
        query = "UPDATE userprofile SET " + cloth + " = array_append(" cloth +", " + index.to_s + ") WHERE login = '';"
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
      checkExist = "select exists(select 1 from userprofile where login = " + line + ");
      uname = line
      res  = @conn.exec(checkExist)
      if res == "true"
        client.puts "GOOD"
        line = client.gets
        query = "UPDATE publishs SET shows = array_append(shows, ROW('" + line + "', TIMESTAMP '" + Time.now.to_s + "')::publishitem) WHERE usrname = '" + uname + "';"
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
        h = Hash.new  
        for i in 0..fieldArray.count-1
          a = []
          res.each do |row|
          a.push(row[fieldArray[i]].lstrip.rstrip)
          end         
        end
        h[fieldArray[i]] = a
        json1 = h.to_json
        reply = client.gets
        puts reply
        puts "data..."
        client.write(json1)
        client.close    
      end
    end
  }
  server.close
end

main
