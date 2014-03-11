############################################################
#                                                          #
#                          hprose                          #
#                                                          #
# Official WebSite: http://www.hprose.com/                 #
#                   http://www.hprose.net/                 #
#                   http://www.hprose.org/                 #
#                                                          #
############################################################

############################################################
#                                                          #
# hprose/tcpserver.rb                                      #
#                                                          #
# hprose tcp server for ruby                               #
#                                                          #
# LastModified: Mar 11, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/io"
require "hprose/service"
require "uri"
require "socket"

module Hprose
  class TcpServer < Service
    def initialize(uri = nil)
      super()
      @host = nil
      @port = 0
      unless uri.nil? then
        u = URI.parse(uri)
        @host = u.host
        @port = u.port
      end
      @sockets = nil
    end
    def host
      @host
    end
    def host=(host)
      @host = host
    end
    def port
      @port
    end
    def port=(port)
      @port = port
    end
    def start
      begin
        @sockets = Socket.tcp_server_sockets(@host, @port)
        @sockets.each do
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
  end # class TcpServer
end # module Hprose