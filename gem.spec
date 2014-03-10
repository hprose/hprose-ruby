require 'rubygems'

spec = Gem::Specification.new {|s|
  s.name     = 'hprose'
  s.version  = '1.4.3'
  s.author   = 'Ma Bingyao ( andot )'
  s.email    = 'andot@hprose.com'
  s.homepage = 'http://www.hprose.com/'
  s.platform = Gem::Platform::RUBY
  s.summary  = 'Hprose is a lightweight, secure, cross-domain,
                platform-independent, language-independent,
                envirment-independent, complex object supported,
                reference parameters supported, session supported,
                service-oriented, high performance remote object
                service engine. This project is the client and
                server implementations of the Hprose for Ruby.'
  candidates = Dir.glob '{examples,lib}/**/*'
  candidates += Dir.glob '*'
  s.files    = candidates.delete_if { |item|
                 item.include?('CVS') || item.include?('rdoc') ||
                 item.include?('nbproject') ||
                 File.extname(item) == '.spec' ||
                 File.extname(item) == '.gem'
               }
  s.require_path = 'lib'
  s.has_rdoc     = false
}

if $0 == __FILE__
  Gem::Builder.new(spec).build
end