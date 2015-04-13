############################################################
#                                                          #
#                          hprose                          #
#                                                          #
# Official WebSite: http://www.hprose.com/                 #
#                   http://www.hprose.org/                 #
#                                                          #
############################################################

############################################################
#                                                          #
# hprose/socketserver.rb                                   #
#                                                          #
# hprose socket server for ruby                            #
#                                                          #
# LastModified: Apr 13, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/service"
require "uri"
require "socket"

module Hprose
  class SocketServer < Service
    protected
    def create_server_sockets
      raise NotImplementedError.new("#{self.class.name}#create_server_sockets is an abstract method")
    end
    public
    def initialize(uri = nil)
      super()
      @uri = nil
      unless uri.nil? then
        @uri = URI.parse(uri)
      end
      @sockets = nil
    end
    def start
      begin
        create_server_sockets
        Socket.accept_loop(@sockets) do |sock, client_addrinfo|
          Thread.start do
            begin
              loop do
                buf = sock.recv(4, 0)
                n = buf[0].ord << 24 | buf[1].ord << 16 | buf[2].ord << 8 | buf[3].ord
                data = handle(sock.recv(n, 0), client_addrinfo)
                n = data.size
                sock.send("" << (n >> 24 & 0xff) << (n >> 16 & 0xff) << (n >> 8 & 0xff) << (n & 0xff) << data, 0)
              end
            ensure
              sock.close
            end
          end
        end
      rescue ::Interrupt => e
      ensure
        stop
      end
    end
    def stop
      unless @sockets.nil? then
         @sockets.each {|s| s.close if !s.closed? }
         @sockets = nil
      end
    end
  end # class SocketServer
end # module Hprose