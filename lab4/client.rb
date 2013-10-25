require '../spolks_lib/connection'
require '../spolks_lib/utils'

MSG = '?'

opts = Utils::ArgParser.new
opts.parse!

client = nil

File.open(opts[:filepath], File::RDONLY) do |file|
    begin
      client = Connection::SocketTCP.new(opts[:port],opts[:addr])
      client.sock_connect
      
      sent = true
      transferred = 0
      counter = 0

      loop do
        _, write_buf, = IO.select(nil, [client], nil, Connection::CON_TIMEOUT)

        break unless write_buf
        data, sent = file.read(Connection::EXG_SIZE), false if sent

        if s = write_buf.shift
          break unless data
          sent = true unless s.send(data, 0) == 0
          counter += 1
          transferred += data.length if sent
          if counter == 10
            s.send(MSG, Connection::SocketTCP::MSG_OOB)
            puts transferred 
            counter = 0
          end
        end
      end
    ensure
      client.close if client
    end
  end
