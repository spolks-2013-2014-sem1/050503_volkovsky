require '../spolks_lib/connection'
require '../spolks_lib/utils'

opts = Utils::ArgParser.new
opts.parse!

addr = opts[:ip] || 'localhost'
port = opts[:port] || 2000

socket = Connection::TCPSocket.new;
socket.sock_bind(addr, port)
puts "server is running on #{addr}:#{port}"

loop do
  Thread.start(socket.sysaccept) do |client_fd, _|
    loop do
      client_socket = Socket.for_fd(client_fd)
      command = client_socket.gets.chomp
      if command == "exit"
        client_socket.puts "Bye bye!"
        client_socket.close
      else
        client_socket.puts command
      end
    end
  end
end
