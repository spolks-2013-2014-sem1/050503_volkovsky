require '../spolks_lib/connection'
require '../spolks_lib/utils'

opts = Utils::ArgParser.new
opts.parse!

server = nil
addr = opts[:addr] || '127.0.0.1'
port = opts[:port] || 2000

File.open(opts[:filepath], File::CREAT|File::TRUNC|File::WRONLY) do |file|
  begin
    if opts[:udp]
      puts "UDP connection"
      server = Connection::SocketUDP.new(port, addr)
      server.sock_bind
    else
      socket = Connection::SocketTCP.new(port, addr)
      socket.sock_bind
      server,_ = server.accept
    end 

    loop do
      ready_to_read,_,_ = IO.select([server],nil, nil, Connection::CON_TIMEOUT)
      break unless ready_to_read
      if s = ready_to_read.shift
        data = s.recv(Connection::EXG_SIZE)
        break if data.empty?
        file.write(data)
      end
    end
  ensure
    puts "Transfer completed" 
    server.close if server
  end
end
