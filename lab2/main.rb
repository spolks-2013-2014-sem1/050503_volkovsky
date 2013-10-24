require '../spolks_lib/connection'
require '../spolks_lib/utils'

opts = Utils::ArgParser.new
opts.parse!

addr = opts[:ip] || 'localhost'
port = opts[:port] || 2000

server = Connection::SocketTCP.new(port,addr)
server.sock_bind

puts "server is running on #{addr}:#{port}"

loop do
  Thread.start(server.accept) do |client, _|
    loop do
      command = client.gets.chomp
      if command == "exit"
        client.puts "Bye bye!"
        client.close
      else
        client.puts command
      end
    end
  end
end
