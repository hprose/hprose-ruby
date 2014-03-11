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
# hproseserver.rb                                          #
#                                                          #
# hprose server for ruby                                   #
#                                                          #
# LastModified: Mar 11, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

module Hprose
  autoload :Service, 'hprose/service'
  autoload :HttpService, 'hprose/httpservice'
  autoload :TcpServer, 'hprose/tcpserver'
end

Object.const_set(:HproseService, Hprose.const_get(:Service))
Object.const_set(:HproseHttpService, Hprose.const_get(:HttpService))
Object.const_set(:HproseTcpServer, Hprose.const_get(:TcpServer))