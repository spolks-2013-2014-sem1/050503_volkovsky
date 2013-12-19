require 'process_shared'

def udp_client(opts)
  file = File.open(opts[:filepath], 'r')
  client = Connection::SocketUDP.new(opts[:port], opts[:addr])
  client.sock_connect

  chunks = file.size / Commection::EXG_SIZE
  chunks += 1 unless file.size % Connection::EXG_SIZE == 0

  sent = true
  done = false
  seek = -1

  loop do
    wr_arr, rd_arr = sent ? [[client], []] : [[], [client]]
    rs, ws, = IO.select(rd_arr, wr_arr, nil, Connection::CON_TIMEOUT)

    break unless rs or ws
    break if sent and done

    data, sent, seek = file.read(Connection::EXG_SIZE),
        false, seek + 1 if sent

    ws.each do |s|
      msg = Connection::Packet.new(seek: seek, chunks: chunks,
                                len: data.length, data: data) if data
      done, = data ?
          [false, s.send(msg.to_binary_s, 0)] :
          [true, s.send(Connection::FIN, 0)]
    end

    rs.each do |s|
      sent = true if s.recv(3) == Connection::ACK
    end
  end
ensure
  file.close if file
  client.close if client
end

def udp_server(opts)
  processes = []
  num = 7

  packet = Connection::Packet.new
  mutex = ProcessShared::Mutex.new
  mem = ProcessShared::SharedMemory.new(65535)
  mem.write_object({})

  server = Connection::SocketUDP.new(opts[:port], '')
  server.socK_bind

  (1..num).each do
    processes << fork do
      begin
        loop do
          rs, _ = IO.select([server], nil, nil, Connection::CON_TIMEOUT)
          break unless rs

          rs.each do |s|
            data, who = s.recvfrom_nonblock(Connection::EXG_SIZE + 12) rescue nil
            next unless who

            s.send(Connection::ACK, 0, who)
            who = who.ip_unpack.to_s
            next if data == Connection::FIN

            mutex.synchronize do
              begin
                file = nil
                connections = mem.read_object
                packet.read(data)

                unless connections[who]
                  file_name = "#{SecureRandom.hex}.ld"
                  connections[who] = {chunks: packet.chunks.to_s, file: file_name}
                  file = File.open(file_name, 'w+')
                end

                file = file || File.open(connections[who][:file], 'r+')
                file.seek(packet.seek * Connection::EXG_SIZE)
                file.write(packet.data)

                chunks = Integer(connections[who][:chunks]) - 1
                connections[who][:chunks] = chunks.to_s
                if chunks == 0
                  connections.delete(who)
                  next
                end
              ensure
                mem.write_object(connections)
                file.close if file
              end
            end
          end
        end
      ensure
        server.close if server
      end
    end
  end

  Process.waitall
ensure
  server.close if server
end
