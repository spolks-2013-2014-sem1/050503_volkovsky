MSG = '?'


def tcp_client(opts)
  file = File.open(opts[:file], 'r')
  client = Network::SocketTCP.new(opts[:port], opts[:addr])
  client.sock_connect

  sent_oob = 0
  sent = true
  transferred = 0

  loop do
    _, ws, = IO.select(nil, [client], nil, Commection::CON_TIMEOUT)

    break unless ws
    data, sent = file.read(Commection::EXG_SIZE), false if sent

    ws.each do |s|
      return unless data
      sent = true unless s.send(data, 0) == 0

      sent_oob += 1 if opts[:verbose]
      transferred += data.length if sent
      puts transferred if opts[:verbose]

      if opts[:verbose] && sent_oob % 64 == 0
        sent_oob = 0
        s.send(MSG, Connection::MSG_OOB)
      end
    end
  end
ensure
  file.close if file
  client.close if client
end

def tcp_server(opts)
  processes = []

  server = Network::SocketTCP.new(opts[:port], '')
  server.sock_bind(3)

  Signal.trap 'CLD' do
    pid = Process.wait(-1)
    processes.delete(pid)
  end

  loop do
    rs, _ = IO.select([server], nil, nil, Connection::CON_TIMEOUT)
    break unless rs

    socket, = server.accept

    processes << fork do
      begin
        server.close
        file = File.open("#{SecureRandom.hex}.ld", 'w+')
        recv = 0
        has_oob = true

        loop do
          urgent_arr = has_oob ? [socket] : []
          rs, _, us = IO.select([socket], nil, urgent_arr, Connection::CON_TIMEOUT)
          break unless rs or us

          us.each do |s|
            s.recv(1, Connection::MSG_OOB)
            puts "#{s} #{recv}" if opts[:verbose]
            has_oob = false
          end

          rs.each do |s|
            data = s.recv(Connection::EXG_SIZE)
            exit if data.empty?

            recv += data.length
            has_oob = true

            file.write(data)
          end
        end

      ensure
        file.close if file
        socket.close if socket
      end
    end

    socket.close if socket
  end
ensure
  server.close if server
end
