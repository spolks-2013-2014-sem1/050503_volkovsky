require '../spolks_lib/connection'
require '../spolks_lib/utils'

opts = Utils::ArgParser.new
opts.parse!

client = nil

File.open(opts[:filepath], File::RDONLY) do |file|
  begin
    puts "UDP connection" if opts[:udp]
    client = opts[:udp] ? Connection::SocketUDP.new(opts[:port],opts[:addr])
                        : Connection::SocketTCP.new(opts[:port],opts[:addr])
    client.sock_connect
    sent = true
    loop do
      _, ready_to_write, = IO.select(nil, [client], nil, Connection::CON_TIMEOUT)
      break unless ready_to_write
      data, sent = file.read(Connection::EXG_SIZE), false if sent
      if s = ready_to_write.shift
        break unless data
        sent = true unless s.send(data, 0) == 0
      end
    end
  ensure
    puts "Transvfer completed"
    client.close if client
  end
end
