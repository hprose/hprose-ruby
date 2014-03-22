require 'rubygems'

spec = Gem::Specification.new {|s|
  s.name        = 'hprose'
  s.version     = '1.4.11'
  s.license     = 'MIT'
  s.author      = 'Ma Bingyao ( andot )'
  s.email       = 'andot@hprose.com'
  s.homepage    = 'http://www.hprose.com/'
  s.platform    = Gem::Platform::RUBY
  s.description = <<-EOF
  Hprose is a High Performance Remote Object Service Engine.

  It is a modern, lightweight, cross-language, cross-platform, object-oriented, high performance, remote dynamic communication middleware. It is not only easy to use, but powerful. You just need a little time to learn, then you can use it to easily construct cross language cross platform distributed application system.

  Hprose supports many programming languages.

  Through Hprose, You can conveniently and efficiently intercommunicate between those programming languages.

  This project is the implementation of Hprose for Ruby.
EOF

  s.summary     = 'Hprose is a lightweight, secure, cross-domain,
                   platform-independent, language-independent,
                   envirment-independent, complex object supported,
                   reference parameters supported, session supported,
                   service-oriented, high performance remote object
                   service engine. This project is the client and
                   server implementations of the Hprose for Ruby.'
  candidates    = Dir.glob '{examples,lib}/**/*'
  candidates   += Dir.glob '*'
  s.files       = candidates.delete_if { |item|
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