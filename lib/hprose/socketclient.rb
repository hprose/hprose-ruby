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
# hprose/socketclient.rb                                   #
#                                                          #
# hprose socket client for ruby                            #
#                                                          #
# LastModified: Apr 13, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/client"
require "socket"

module Hprose
  class SocketClient < Client
    private
      module SocketConnStatus
        Free = 0
        Using = 1
        Closing = 2
      end
      class SocketConnEntry
        def initialize(uri)
          @uri = uri
          @status = SocketConnStatus::Using
          @socket = nil
        end
        attr_accessor :uri, :status, :socket
      end
      class SocketConnPool
        def initialize
          @pool = []
          @mutex = Mutex.new
        end
        def get(uri)
          @mutex.synchronize do
            @pool.each do |entry|
              if entry.status == SocketConnStatus::Free then
                if not entry.uri.nil? and entry.uri == uri then
                  entry.status = SocketConnStatus::Using
                  return entry
                elsif entry.uri.nil? then
                  entry.status = SocketConnStatus::Using
                  entry.uri = uri
                  return entry
                end
              end
            end
            entry = SocketConnEntry.new(uri)
            @pool << entry
            return entry
          end
        end
        def close(uri)
          sockets = []
          @mutex.synchronize do
            @pool.each do |entry|
              if not entry.uri.nil? and entry.uri == uri then
                if entry.status == SocketConnStatus::Free then
                  sockets << entry.socket
                  entry.socket = nil
                  entry.uri = nil
                else
                  entry.status = SocketConnStatus::Closing
                end
              end
            end
          end
          freeSockets(sockets)
        end
        def free(entry)
          if entry.status == SocketConnStatus::Closing then
            if not entry.socket.nil? then
              entry.socket.close
              entry.socket = nil
            end
            entry.uri = nil
          end
          entry.status = SocketConnStatus::Free
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
      @pool = SocketConnPool.new
    end
    protected
    def create_socket
      raise NotImplementedError.new("#{self.class.name}#create_socket is an abstract method")
    end
    def send_and_receive(data)
      entry = @pool.get(@uri)
      if entry.socket.nil? then
        entry.socket = create_socket
      end
      begin
        n = data.bytesize
        entry.socket.send("" << (n >> 24 & 0xff) << (n >> 16 & 0xff) << (n >> 8 & 0xff) << (n & 0xff) << data, 0)
        buf = entry.socket.recv(4, 0)
        n = buf[0].ord << 24 | buf[1].ord << 16 | buf[2].ord << 8 | buf[3].ord
        data = entry.socket.recv(n, 0)
      rescue
        entry.status = SocketConnStatus::Closing
        raise
      ensure
        @pool.free(entry)
      end
      return data
    end
  end # class SocketClient
end # module Hprose