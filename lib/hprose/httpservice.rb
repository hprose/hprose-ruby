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
# hprose/httpservice.rb                                    #
#                                                          #
# hprose http service for ruby                             #
#                                                          #
# LastModified: Mar 12, 2014                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require 'hprose/io'
require 'hprose/service'

module Hprose
  class HttpService < Service
    def initialize
      super
      @crossdomain = false
      @p3p = false
      @get = true
      @crossdomain_xml_file = nil
      @crossdomain_xml_content = nil
      @client_access_policy_xml_file = nil
      @client_access_policy_xml_content = nil
      @on_send_header = nil
    end
    attr_accessor :crossdomain
    attr_accessor :p3p
    attr_accessor :get
    attr_accessor :on_send_header
    attr_reader :crossdomain_xml_file
    attr_reader :crossdomain_xml_content
    attr_reader :client_access_policy_xml_file
    attr_reader :client_access_policy_xml_content
    def crossdomain_xml_file=(filepath)
      @crossdomain_xml_file = filepath
      f = File.open(filepath)
      begin
        @crossdomain_xml_content = f.read
      ensure
        f.close
      end
    end
    def crossdomain_xml_content=(content)
      @crossdomain_xml_file = nil
      @crossdomain_xml_content = content
    end
    def client_access_policy_xml_file=(filepath)
      @client_access_policy_xml_file = filepath
      f = File.open(filepath)
      begin
        @client_access_policy_xml_content = f.read
      ensure
        f.close
      end
    end
    def client_access_policy_xml_content=(content)
      @client_access_policy_xml_file = nil
      @client_access_policy_xml_content = content
    end
    def call(context)
      unless @client_access_policy_xml_content.nil? then
        result = client_access_policy_xml_handler(context)
        return result if result
      end
      unless @crossdomain_xml_content.nil? then
        result = crossdomain_xml_handler(context)
        return result if result
      end
      header = default_header(context)
      begin
        statuscode = 200
        if (context['REQUEST_METHOD'] == 'GET') and @get then
          body = do_function_list
        elsif (context['REQUEST_METHOD'] == 'POST') then
          body = handle(context['rack.input'].read, context)
        else
          statuscode = 403
          body = 'Forbidden'
        end
      rescue ::Exception => e
        body = do_error(e)
      end
      header['Content-Length'] = body.size.to_s
      return [statuscode, header, [body]]
    end
    private
    def crossdomain_xml_handler(context)
      path = (context['SCRIPT_NAME'] << context['PATH_INFO']).downcase
      if path == '/crossdomain.xml' then
        if context['HTTP_IF_MODIFIED_SINCE'] == @last_modified and
          context['HTTP_IF_NONE_MATCH'] == @etag then
          return [304, {}, ['']]
        else
          header = {'Content-Type' => 'text/xml',
                    'Last-Modified' => @last_modified,
                    'Etag' => @etag,
                    'Content-Length' => @crossdomain_xml_content.size.to_s}
          return [200, header, [@crossdomain_xml_content]]
        end
      end
      return false
    end
    def client_access_policy_xml_handler(context)
      path = (context['SCRIPT_NAME'] << context['PATH_INFO']).downcase
      if path == '/clientaccesspolicy.xml' then
        if context['HTTP_IF_MODIFIED_SINCE'] == @last_modified and
          context['HTTP_IF_NONE_MATCH'] == @etag then
          return [304, {}, ['']]
        else
          header = {'Content-Type' => 'text/xml',
                    'Last-Modified' => @last_modified,
                    'Etag' => @etag,
                    'Content-Length' => @client_access_policy_xml_content.size.to_s}
          return [200, header, [@client_access_policy_xml_content]]
        end
      end
      return false
    end
    def default_header(context)
      header = {'Content-Type' => 'text/plain'}
      header['P3P'] = 'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD ' +
        'IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi ' +
        'PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT ' +
        'STA POL HEA PRE GOV"' if @p3p
      if @crossdomain then
        origin = context['HTTP_ORIGIN']
        if (origin and origin != 'null') then
          header['Access-Control-Allow-Origin'] = origin
          header['Access-Control-Allow-Credentials'] = 'true'
        else
          header['Access-Control-Allow-Origin'] = '*'
        end
      end
      @on_send_header.call(header, context) unless @on_send_header.nil?
      return header
    end
  end # class HttpService
end # module Hprose