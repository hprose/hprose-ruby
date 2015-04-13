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
# hprose/tcpserver.rb                                      #
#                                                          #
# hprose tcp server for ruby                               #
#                                                          #
# LastModified: Apr 13, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/socketserver"
require "socket"

module Hprose
  class TcpServer < SocketServer
    def initialize(uri = nil)
      super
      @host = nil
      @port = 0
      unless uri.nil? then
        @host = @uri.host
        @port = @uri.port
      end
      @sockets = nil
    end
    attr_accessor :host, :port
    protected
    def create_server_sockets
      @sockets = Socket.tcp_server_sockets(@host, @port)
    end
  end # class TcpServer
end # module Hprose