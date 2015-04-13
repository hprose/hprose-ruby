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
# hprose/tcpclient.rb                                      #
#                                                          #
# hprose tcp client for ruby                               #
#                                                          #
# LastModified: Apr 13, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/socketclient"
require "socket"

module Hprose
  class TcpClient < SocketClient
    protected
    def create_socket
      return TCPSocket.new(@uri.host, @uri.port)
    end
  end # class TcpClient
end # module Hprose