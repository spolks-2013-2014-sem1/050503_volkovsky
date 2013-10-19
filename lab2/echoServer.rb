require 'socket'
include Socket::Constants

port = ARGV[0] ? ARGV[0] : 2000

socket = Socket.new(AF_INET, SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(port, "localhost")

socket.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)
socket.bind(sockaddr)
puts "server is running on localhost:#{port}"

socket.listen(5)

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
