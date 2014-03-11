require 'rubygems'
require 'rack'
require 'hprose'

def hello(name)
  return 'hello ' << name << '!'
end

class User
  def initialize()
    @name = "Tom"
    @age = 28
  end
end

def getUser()
  return User.new()
end


class MyService
  def add(a, b)
    return a + b
  end
  def sub(a, b)
    return a - b
  end
end

def mf(name, args)
  return name << " => " << HproseFormatter.serialize(args)
end

HproseClassManager.register(User, "User")

server = HproseTcpServer.new
server.port = 4321

server.add(:hello)
server.add(:sum) { |*num|
  result = 0
  num.each { |item| result += item }
  result
}
server.add(:getUser)
server.add_missing_function(:mf)
server.add(MyService.new, :math)
server.debug = true
server.start