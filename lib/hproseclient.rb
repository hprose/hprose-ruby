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
# hproseclient.rb                                          #
#                                                          #
# hprose client for ruby                                   #
#                                                          #
# LastModified: Mar 10, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

module Hprose
  autoload :Client, 'hprose/client'
  autoload :HttpClient, 'hprose/httpclient'
  autoload :SocketClient, 'hprose/socketclient'
  autoload :TcpClient, 'hprose/tcpclient'
  autoload :UnixClient, 'hprose/unixclient'
end

Object.const_set(:HproseClient, Hprose.const_get(:Client))
Object.const_set(:HproseHttpClient, Hprose.const_get(:HttpClient))
Object.const_set(:HproseSocketClient, Hprose.const_get(:SocketClient))
Object.const_set(:HproseTcpClient, Hprose.const_get(:TcpClient))
Object.const_set(:HproseUnixClient, Hprose.const_get(:UnixClient))