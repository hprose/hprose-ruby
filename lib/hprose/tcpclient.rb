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
# hprose/tcpclient.rb                                      #
#                                                          #
# hprose tcp client for ruby                               #
#                                                          #
# LastModified: Mar 10, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/client"
require "socket"

module Hprose
  class TcpClient < Client
    private
      module TcpConnStatus
        Free = 0
        Using = 1
        Closing = 2
      end
      class TcpConnEntry
        def initialize(uri)
          @uri = uri
          @status = TcpConnStatus::Using
          @socket = nil
        end
        attr_accessor :uri, :status, :socket
      end
      class TcpConnPool
        def initialize
          @pool = []
          @mutex = Mutex.new
        end
        def get(uri)
          @mutex.synchronize do
            @pool.each do |entry|
              if entry.status == TcpConnStatus::Free then
                if not entry.uri.nil? and entry.uri == uri then
                  entry.status = TcpConnStatus::Using
                  return entry
                elsif entry.uri.nil? then
                  entry.status = TcpConnStatus::Using
                  entry.uri = uri
                  return entry
                end
              end
            end
            entry = TcpConnEntry.new(uri)
            @pool << entry
            return entry
          end
        end
        def close(uri)
          sockets = []
          @mutex.synchronize do
            @pool.each do |entry|
              if not entry.uri.nil? and entry.uri == uri then
                if entry.status == TcpConnStatus::Free then
                  sockets << entry.socket
                  entry.socket = nil
                  entry.uri = nil
                else
                  entry.status = TcpConnStatus::Closing
                end
              end
            end
          end
          freeSockets(sockets)
        end
        def free(entry)
          if entry.status == TcpConnStatus::Closing then
            if not entry.socket.nil? then
              entry.socket.close
              entry.socket = nil
            end
            entry.uri = nil
          end
          entry.status = TcpConnStatus::Free
        end
        private
        def freeSockets(sockets)
          Thread.start do
            sockets.each do |socket|
              socket.close
            end
          end
        end
      end
    public
    def initialize(uri = nil)
      super
      @pool = TcpConnPool.new
    end
    protected
    def send_and_receive(data)
      entry = @pool.get(@uri)
      if entry.socket.nil? then
        entry.socket = TCPSocket.new(@uri.host, @uri.port)
      end
      begin
        n = data.size
        entry.socket.send("" << (n >> 24 & 0xff) << (n >> 16 & 0xff) << (n >> 8 & 0xff) << (n & 0xff) << data, 0)
        buf = entry.socket.recv(4, 0)
        n = buf[0].ord << 24 | buf[1].ord << 16 | buf[2].ord << 8 | buf[3].ord
        data = entry.socket.recv(n, 0)
      rescue
        entry.status = TcpConnStatus::Closing
        raise
      ensure
        @pool.free(entry)
      end
      return data
    end
  end # class TcpClient
end # module Hprose