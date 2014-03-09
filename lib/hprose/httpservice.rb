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
# LastModified: Mar 8, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/io"
require "hprose/service"

module Hprose
  class HttpService < Service
    attr_accessor :crossdomain
    attr_accessor :p3p
    attr_accessor :get
    attr_accessor :on_send_header
    def initialize
      super
      @crossdomain = false
      @p3p = false
      @get = true
      @on_send_header = nil
    end
    def call(context)
      header = {'Content-Type' => 'text/plain'}
      header['P3P'] = 'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD ' +
        'IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi ' +
        'PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT ' +
        'STA POL HEA PRE GOV"' if @p3p
      if @crossdomain then
        origin = context["HTTP_ORIGIN"]
        if (origin and origin != "null") then
          header['Access-Control-Allow-Origin'] = origin
          header['Access-Control-Allow-Credentials'] = 'true'
        else
          header['Access-Control-Allow-Origin'] = '*'
        end
      end
      begin
        statuscode = 200
        @on_send_header.call(header) unless @on_send_header.nil?
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
    protected
    def fix_args(args, arity, context)
      session = context['rack.session'] ? context['rack.session'] : {}
      ((arity > 0) and (args.length + 1 == arity)) ? args + [session] : args
    end
  end # class HttpService
end # module Hprose