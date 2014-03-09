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
# hprose/client.rb                                         #
#                                                          #
# hprose client for ruby                                   #
#                                                          #
# LastModified: Mar 8, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/common"
require "hprose/io"

module Hprose
  class Client
    include Tags
    include ResultMode
    public
    def initialize(uri = nil)
      @onerror = nil
      @filter = Filter.new
      @simple = false
      self.uri = uri
    end
    def uri=(uri)
      @uri = URI.parse(uri) unless uri.nil?
    end
    attr_reader :uri
    attr_accessor :filter, :simple
    def onerror(&block)
      @onerror = block if block_given?
      @onerror
    end
    def onerror=(error_handler)
      error_handler = error_handler.to_sym if error_handler.is_a?(String)
      if error_handler.is_a?(Symbol) then
        error_handler = Object.method(error_handler)
      end
      @onerror = error_handler
    end
    def use_service(uri = nil, namespace = nil)
      self.uri = uri
      Proxy.new(self, namespace)
    end
    def [](namespace)
      Proxy.new(self, namespace)
    end
    def invoke(methodname, args = [], byref = false, resultMode = Normal, simple = nil, &block)
      simple = @simple if simple.nil?
      if block_given? then
        Thread.start do
          begin
            result = do_invoke(methodname, args, byref, resultMode, simple)
            case block.arity
            when 0 then yield
            when 1 then yield result
            when 2 then yield result, args
            end
          rescue ::Exception => e
            @onerror.call(methodname, e) if (@onerror.is_a?(Proc) or
                                             @onerror.is_a?(Method) or
                                             @onerror.respond_to?(:call))
          end
        end
      else
        return do_invoke(methodname, args, byref, resultMode, simple)
      end
    end
    protected
    def send_and_receive(data)
      raise NotImplementedError.new("#{self.class.name}#send_and_receive is an abstract method")
    end
    private
    def do_output(methodname, args, byref, simple)
      stream = StringIO.new
      writer = Writer.new(stream, simple)
      stream.putc(TagCall)
      writer.write_string(methodname.to_s)
      if (args.size > 0 or byref) then
        writer.reset
        writer.write_list(args)
        writer.write_boolean(true) if byref
      end
      stream.putc(TagEnd)
      data = @filter.output_filter(stream.string)
      stream.close
      return data
    end
    def do_input(data, args, resultMode)
      data = @filter.input_filter(data)
      raise Exception.exception("Wrong Response: \r\n#{data}") if data[data.size - 1].ord != TagEnd
      return data if resultMode == RawWithEndTag
      return data.chop! if resultMode == Raw
      stream = StringIO.new(data, 'rb')
      reader = Reader.new(stream)
      result = nil
      while (tag = stream.getbyte) != TagEnd do
        case tag
        when TagResult then
          if resultMode == Normal then
            reader.reset
            result = reader.unserialize
          else
            s = reader.read_raw
            result = s.string
            s.close
          end
        when TagArgument then
          reader.reset
          a = reader.read_list
          args.each_index { |i| args[i] = a[i] }
        when TagError then
          reader.reset
          result = Exception.exception(reader.read_string())
        else
          raise Exception.exception("Wrong Response: \r\n#{data}")
        end
      end
      return result
    end
    def do_invoke(methodname, args, byref, resultMode, simple)
      data = do_output(methodname, args, byref, simple)
      result = do_input(send_and_receive(data), args, resultMode)
      raise result if result.is_a?(Exception)
      return result
    end
    def method_missing(methodname, *args, &block)
      self.invoke(methodname, args, &block)
    end

    class Proxy
      def initialize(client, namespace = nil)
        @client = client
        @namespace = namespace
      end
      def [](namespace)
        Proxy.new(@client, @namespace.to_s + '_' + namespace.to_s)
      end
      def method_missing(methodname, *args, &block)
        methodname = @namespace.to_s + '_' + methodname.to_s unless @namespace.nil?
        @client.invoke(methodname, args, &block)
      end
    end # class Proxy
  end # class Client
end # module Hprose