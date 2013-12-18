require 'socket'
require 'bindata'

module Connection
  
  EXG_SIZE = 1024
  CON_TIMEOUT = 10 
  ACK = 'ACK'
  FIN = 'FIN'

  class Packet < BinData::Record
    endian :little
    uint32 :chunks
    uint32 :len
    uint32 :seek
    string :data, :read_length => :len
  end

  class SocketTCP < Socket
    def initialize(port,addr)
      super(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      @sockaddr = Socket.sockaddr_in(port, addr) 
    end

    def sock_bind(queue = 1)
      bind(@sockaddr)
      listen(queue)
    end

    def sock_connect
      connect(@sockaddr)
    end
  end

  class SocketUDP < Socket
    def initialize(port,addr)
      super(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      @sockaddr = Socket.sockaddr_in(port, addr)
    end    

    def sock_bind
      bind(@sockaddr)
    end

    def sock_connect
      connect(@sockaddr)
    end
  end
end
