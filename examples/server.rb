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

app = HproseHttpService.new()

app.add(:hello)
app.add(:sum) { |*num|
  result = 0
  num.each { |item| result += item }
  result
}
app.add(:getUser)
app.add_missing_function(:mf)
app.add(MyService.new, :math)
app.debug = true
Rack::Handler::WEBrick.run(app, {:Port => 3000})
