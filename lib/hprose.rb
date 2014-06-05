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
# hprose.rb                                                #
#                                                          #
# hprose for ruby                                          #
#                                                          #
# LastModified: Mar 11, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

module Hprose
  autoload :Exception, 'hprose/common'
  autoload :ResultMode, 'hprose/common'
  autoload :Filter, 'hprose/common'
  autoload :Tags, 'hprose/io'
  autoload :ClassManager, 'hprose/io'
  autoload :RawReader, 'hprose/io'
  autoload :Reader, 'hprose/io'
  autoload :Writer, 'hprose/io'
  autoload :Formatter, 'hprose/io'
  autoload :Client, 'hprose/client'
  autoload :HttpClient, 'hprose/httpclient'
  autoload :TcpClient, 'hprose/tcpclient'
  autoload :Service, 'hprose/service'
  autoload :HttpService, 'hprose/httpservice'
  autoload :TcpServer, 'hprose/tcpserver'
end

Object.const_set(:HproseException, Hprose.const_get(:Exception))
Object.const_set(:HproseResultMode, Hprose.const_get(:ResultMode))
Object.const_set(:HproseFilter, Hprose.const_get(:Filter))
Object.const_set(:HproseTags, Hprose.const_get(:Tags))
Object.const_set(:HproseClassManager, Hprose.const_get(:ClassManager))
Object.const_set(:HproseRawReader, Hprose.const_get(:RawReader))
Object.const_set(:HproseReader, Hprose.const_get(:Reader))
Object.const_set(:HproseWriter, Hprose.const_get(:Writer))
Object.const_set(:HproseFormatter, Hprose.const_get(:Formatter))
Object.const_set(:HproseClient, Hprose.const_get(:Client))
Object.const_set(:HproseHttpClient, Hprose.const_get(:HttpClient))
Object.const_set(:HproseTcpClient, Hprose.const_get(:TcpClient))
Object.const_set(:HproseService, Hprose.const_get(:Service))
Object.const_set(:HproseHttpService, Hprose.const_get(:HttpService))
Object.const_set(:HproseTcpServer, Hprose.const_get(:TcpServer))