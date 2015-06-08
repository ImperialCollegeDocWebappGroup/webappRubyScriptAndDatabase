require 'pg'
require 'socket'
require 'json'
require 'base64'
require 'pp'

def main
  server = TCPServer.new 1111 # Server bind to port 1111
  loop {        # Servers run forever
    # Thread.start(server.accept) do |client|
    client = server.accept    # Wait for a client to connect
    line = client.gets
    puts line
    File.open('shipping_label.jpeg', 'wb') do|f|
      f.write(Base64.decode64(line))
    end
    client.puts "Sent from server"
    client.close
  }  
  server.close
end

main
