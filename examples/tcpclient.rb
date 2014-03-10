require 'rubygems'
require 'hprose'

client = HproseClient.new('tcp://127.0.0.1:4321/')
def error(name, e)
  puts name
  puts e
end
client.onerror = :error

puts(client.hello('World'))
