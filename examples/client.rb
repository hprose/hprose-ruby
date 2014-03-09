require 'rubygems'
require 'hprose'

client = HproseHttpClient.new('http://localhost:3000/')
def error(name, e)
  puts name
  puts e
end
client.onerror = :error

math = client.use_service(nil, :math)

client.hello('World') { |result|
  puts result
}

math.add(1, 2) { |result|
  puts result
}.join

math.sub(1, 2) { |result|
  puts result
}.join

puts client.sum(1,3,4,5,6,7)
user = client.getUser()
puts user.name
puts user.age

puts client.hi('hprose')
puts client.push([user, user, user])
