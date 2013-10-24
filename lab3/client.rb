require '../spolks_lib/connection'
require '../spolks_lib/utils'

opts = Utils::ArgParser.new
opts.parse!

client = nil

File.open(opts[:filepath], File::RDONLY) do |file|
    begin
      client = Connection::SocketTCP.new(opts[:port]opts[:addr])
      client.sock_connect
      sent = true

      loop do
        _, write_buf, = IO.select(nil, [client], nil, Connection::CON_TIMEOUT)

        break unless write_buf
        data, sent = file.read(Connection::EXG_SIZE), false if sent

        if s = write_buf.shift
          break unless data
          sent = true unless s.send(data, 0) == 0
        end
      end
    ensure
      client.close if client
    end
  end
