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
# hprose/unixclient.rb                                     #
#                                                          #
# hprose unix client for ruby                              #
#                                                          #
# LastModified: Apr 13, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/socketclient"
require "socket"

module Hprose
  class UnixClient < SocketClient
    protected
    def create_socket
      return UNIXSocket.new(@uri.path)
    end
  end # class UnixClient
end # module Hprose