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
  countFileName = "picCount.txt"
  index = 0
  if File.exist?(filePath + countFileName)
    index = File.read(filePath+countFileName)
  else
    File.open(filePath+countFileName, 'w') { |file| file.write("0") }
  end
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
  puts index
  loop {
    puts "new loop"
    client = server.accept
    puts "client accpetd"
    line = client.gets
    line = line.lstrip.rstrip
    puts line
    if (line == "SP")
      puts "save and publish confirm"
      client.puts "GOOD"
      line = client.gets
      line = line.lstrip.rstrip
      puts line
      checkExist = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = '" + line + "');"
      res  = @conn.exec(checkExist)
      result = res[0]["exists"] 
      if result == "t"
        client.puts "GOOD2"
        fileName = filePath + "picFile" + index.to_s + ".jpeg"
        name = line
        line = client.gets
        line = line.lstrip.rstrip
        File.open(fileName, 'wb') do|f|
          f.write(Base64.decode64(line))
        end
        puts "saved"
        savedName = "picFile" + index.to_s + ".jpeg"
        puts savedName
        client.puts "GOOD3"
        cont = client.gets
        cont = line.lstrip.rstrip
        query = "UPDATE publishs SET shows = array_append(shows, ROW('" + cont + "', LOCALTIMESTAMP,ARRAY[]::comment[],'" + savedName + "',0,'')::publishitem) WHERE usrname = '"+name+"';"
        puts query
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
        index = Integer(index) + 1
        File.open(filePath+countFileName, 'w') { |file| file.write(index) }
        client.puts "SAVEANDPUBLISHDONE"
        client.close
        puts "save done, close"
      else
        puts "save username error"
        client.puts "ERROR"
        client.close
        next
      end
    elsif (line == "SAVE1") || (line == "SAVE2") || (line == "SAVE3")
      cloth = ""
      if line == "SAVE1"
        cloth = "tops"
      elsif line == "SAVE2"
        cloth = "buttoms"
      else
        cloth = "wholelook"
      end
      puts "save confirm"
      client.puts "GOOD"
      line = client.gets
      line = line.lstrip.rstrip
      puts line
      #SELECT EXISTS(SELECT 1 from userprofile WHERE login = 'Sam');
      #line2 = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = 'Sam2');"
      #puts res[0]["exists"]
      checkExist = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = '" + line + "');"
      res  = @conn.exec(checkExist)
      result = res[0]["exists"]
      if result == "t"
        client.puts "GOOD2"
        fileName = filePath + "picFile" + index.to_s + ".jpeg"
        name = line
        line = client.gets
        File.open(fileName, 'wb') do|f|
          f.write(Base64.decode64(line))
        end
        puts "saved"
        query = "UPDATE userprofile SET " + cloth + " = array_append(" + cloth +", 'pic" + index.to_s + "') WHERE login = '" + name + "';"
        puts query
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
        index = Integer(index) + 1
        File.open(filePath+countFileName, 'w') { |file| file.write(index) }
        client.puts "SAVEDONE"
        client.close
        puts "save done, close"
      else
        puts "save username error"
        client.puts "ERROR"
        client.close
        next
      end
    elsif line == "PUBLISH"
      #time = Time.now.to_s
      #SELECT CURRENT_TIMESTAMP(2);
      puts "publish confirm"
      client.puts "GOOD"
      line = client.gets
      puts line
      line = line.lstrip.rstrip
      checkExist = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = '" + line + "');"
      puts checkExist
      uname = line
      res  = @conn.exec(checkExist)
      result2 = res[0]["exists"]
      puts result2
      if result2 == "t"
        client.puts "GOOD2"
        puts "good2"
        line2 = client.gets
        puts line2
        query = "UPDATE publishs SET shows = array_append(shows, ROW('" + line2 + "', LOCALTIMESTAMP,ARRAY[]::comment[],'',0,'')::publishitem) WHERE usrname = '"+uname+"';"
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
          client.close
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
    elsif line == "PUBLISH2"
      #time = Time.now.to_s
      #SELECT CURRENT_TIMESTAMP(2);
      puts "publish2 confirm"
      client.puts "GOOD"
      line = client.gets
      puts line
      line = line.lstrip.rstrip
      checkExist = "SELECT EXISTS(SELECT 1 from userprofile WHERE login = '" + line + "');"
      puts checkExist
      uname = line
      res  = @conn.exec(checkExist)
      result2 = res[0]["exists"]
      puts result2
      if result2 == "t"
        client.puts "GOOD2"
        puts "good2"
        line2 = client.gets
        puts line2
         client.puts "GOOD3"
        puts "good3"
        line3 = client.gets
        puts line3
        query = "UPDATE publishs SET shows = array_append(shows, ROW('" + line3 + "', LOCALTIMESTAMP,ARRAY[]::comment[],'',0,'" + line2 + "')::publishitem) WHERE usrname = '"+uname+"';"
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
          client.close
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
        client.close
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
          h[fieldArray[i]] = a        
        end
        puts h
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

    


    
