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
# hprose/unixserver.rb                                     #
#                                                          #
# hprose unix server for ruby                              #
#                                                          #
# LastModified: Apr 13, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/socketserver"
require "socket"

module Hprose
  class UnixServer < SocketServer
    def initialize(uri = nil)
      super(uri)
      @path = nil
      unless uri.nil? then
        @path = @uri.path
      end
      @sockets = nil
    end
    attr_accessor :path
    protected
    def create_server_sockets
      @sockets = Socket.unix_server_socket(@path)
    end
  end # class UnixServer
end # module Hprose