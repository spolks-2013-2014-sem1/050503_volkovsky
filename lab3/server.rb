require '../spolks_lib/connection'
require '../spolks_lib/utils'

options = Utils::ArgParser.new
options.parse!

server, income = nil
addr = opts[:ip] || 'localhost'
port = opts[:port] || 2000

File.open(options[:filepath], File::CREAT|File::TRUNC|File::WRONLY) do |file|
    begin
      server = Connection::TCPSocket.new
      server.sock_bind(addr, port)
      income, = server.accept
      loop do
        read_buf, = IO.select([income],nil,nil, Connection::CON_TIMEOUT)
        break unless read_buf

        if s = read_buf.shift
          data = s.recv(Connection::EXG_SIZE)
          break if data.empty?

          file.write(data)
        end
      end
    ensure 
      server.close if server
      income.close if server
    end
  end

