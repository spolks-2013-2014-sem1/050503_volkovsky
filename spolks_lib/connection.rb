require 'socket'

EXG_SIZE = 1024
CON_TIMEOUT = 10

module Connection

  class TCPSocket < Socket
    def initialize
      super(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    end
    
    def sock_bind(addr,port)
      sockaddr = Socket.sockaddr_in(port, addr)
      bind(sockaddr)
      listen(1)
    end

    def sock_connect(addr,port)
      sockaddr = Socket.sockaddr_in(port, addr)
      connect(sockaddr)
    end
  end
end
