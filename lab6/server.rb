require '../spolks_lib/connection'
require '../spolks_lib/utils'

opts = Utils::ArgParser.new
opts.parse!

server,sockets,files = nil
hash = Hash.new

addr = opts[:addr] || '127.0.0.1'
port = opts[:port] || 2000

port_range = port..port+2

begin
  files = port_range.map do |port|
    file = File.open(opts[:filepath]+'/'+port.to_s, File::CREAT|File::TRUNC|File::WRONLY)
    file
  end
  index = 0
  if opts[:udp]
    puts "UDP connection on #{addr}:#{port_range}"
    sockets = port_range.map do |port|
      socket = Connection::SocketUDP.new(port, addr)
      socket.sock_bind
      hash[socket.to_s] = index
      index += 1
      socket
    end
  else
   puts "TCP connection on #{addr}:#{port_range}"
   puts "Waiting for #{port_range.max - port_range.min + 1} connections"  
   sockets = port_range.map do |port|
      socket = Connection::SocketTCP.new(port, addr)
      socket.sock_bind
      income, = socket.accept
      hash[income.to_s] = index
      index += 1
      income
    end
  end
  transfer_end = [false,false,false]
  loop do
    break if transfer_end[0] and transfer_end[1] and transfer_end[2]
    ready_to_read,_,_ = IO.select(sockets,nil,nil, Connection::CON_TIMEOUT)
    break unless ready_to_read
    ready_to_read.each do |socket|
      data = socket.recv(Connection::EXG_SIZE)
      index = hash[socket.to_s]
      transfer_end[index] = true  if data.empty?
      next if data.empty?
      puts 'Read form socket: ' + index.to_s
      files[index].write(data)
    end
  end
ensure 
  puts 'All tranfers completed'
  server.close if server
  sockets.each do |socket|
    socket.close if socket
  end
  files.each do |file|
    file.close if file
  end
end
