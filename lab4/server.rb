require '../spolks_lib/connection'
require '../spolks_lib/utils'

opts = Utils::ArgParser.new
opts.parse!

server, income = nil
addr = opts[:addr] || 'localhost'
port = opts[:port] || 2000

File.open(opts[:filepath], File::CREAT|File::TRUNC|File::WRONLY) do |file|
    begin
      server = Connection::SocketTCP.new(port, addr)
      server.sock_bind
      income, = server.accept
      
      received = 0

      loop do
        read_buf,_,urgent = IO.select([income],nil,[income], Connection::CON_TIMEOUT)
        break unless read_buf
        if s = urgent.shift
          data = s.recv(1, Connection::SocketTCP::MSG_OOB)
          puts received
        end

        if s = read_buf.shift
          data = s.recv(Connection::EXG_SIZE)
          break if data.empty?
          received += data.length
          file.write(data)
        end
      end
    ensure 
      server.close if server
      income.close if server
    end
  end

