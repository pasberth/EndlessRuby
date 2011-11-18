require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "simply example case" do
  
  it "supplimented its source code with 'end'" do

    ER2RB(<<DEFINE).should == 
module HelloEndlessRubyWorld
  def self.hello
    puts "hello endlessruby world"
DEFINE
    <<DEFINE.chomp!
module HelloEndlessRubyWorld
  def self.hello
    puts "hello endlessruby world"
  end
end
DEFINE
  end
end

MODULE = <<DEFINE.chomp!
module Example
DEFINE

CLASS = <<DEFINE.chomp!
class Eample
DEFINE

DEF = <<DEFINE.chomp!
def example
DEFINE

ERSpecHelper.join_blocks([
  MODULE, [
    DEF, []
  ]
])

puts ERSpecHelper.join_blocks([
  MODULE, [
    DEF, []
  ]
], true)

describe "define method case" do

  it "define method" do
    ER2RB(<<DEFINE).should == 
def example
  puts "hello world"
DEFINE
    <<DEFINE.chomp!
def example
  puts "hello world"
end
DEFINE
  end

  it "define class method" do
    ER2RB(<<DEFINE).should == 
def self.example
  puts "hello world"
DEFINE
    <<DEFINE.chomp!
def self.example
  puts "hello world"
end
DEFINE
  end

  it "define singleton method" do
    ER2RB(<<DEFINE).should == 
def obj.example
  puts "hello world"
DEFINE
    <<DEFINE.chomp!
def obj.example
  puts "hello world"
end
DEFINE
  end

end

describe "define module case" do

  it "define module" do
    ER2RB(<<DEFINE).should == 
module Example
  pass
DEFINE
    <<DEFINE.chomp!
module Example
  pass
end
DEFINE
  end


  it "define inner module" do
    ER2RB(<<DEFINE).should == 
module OuterExample::InnerExample
  pass
DEFINE
    <<DEFINE.chomp!
module OuterExample::InnerExample
  pass
end
DEFINE
  end

  it "beggining of the 'module' word method" do
    ER2RB(<<DEFINE).should == 
module_eval()
  pass
DEFINE
    <<DEFINE.chomp!
module_eval()
  pass
DEFINE
  end

end

describe "define class case" do

  it "define class" do
    ER2RB(<<DEFINE).should == 
class Example
DEFINE
    <<DEFINE.chomp!
class Example
end
DEFINE
  end


  it "define inner module" do
    ER2RB(<<DEFINE).should == 
class OuterExample::InnerExample
DEFINE
    <<DEFINE.chomp!
class OuterExample::InnerExample
end
DEFINE
  end

  it "beggining of the 'class' word method" do
    ER2RB(<<DEFINE).should == 
class_eval()
DEFINE
    <<DEFINE.chomp!
class_eval()
DEFINE
  end

end

describe "if expression case" do

  it "without parenthesis" do
    ER2RB(<<DEFINE).should == 
if flg
  pass
DEFINE
    <<DEFINE.chomp!
if flg
  pass
end
DEFINE
  end

  it "parenthesis" do
    ER2RB(<<DEFINE).should == 
if(flg)
  pass
DEFINE
    <<DEFINE.chomp!
if(flg)
  pass
end
DEFINE
  end

  it "then and without parenthesis" do
    ER2RB(<<DEFINE).should == 
if flg then
  pass
DEFINE
    <<DEFINE.chomp!
if flg then
  pass
end
DEFINE
  end

  it "then and parenthesis" do
    ER2RB(<<DEFINE).should == 
if(flg) then
  pass
DEFINE
    <<DEFINE.chomp!
if(flg) then
  pass
end
DEFINE
  end

  it "else and without parenthesis" do
    ER2RB(<<DEFINE).should == 
if flg
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
if flg
  pass
else
  pass
end
DEFINE
  end

  it "else and parenthesis" do
    ER2RB(<<DEFINE).should == 
if(flg)
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
if(flg)
  pass
else
  pass
end
DEFINE
  end

  it "else and then and without parenthesis" do
    ER2RB(<<DEFINE).should == 
if flg then
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
if flg then
  pass
else
  pass
end
DEFINE
  end

  it "else and then and parenthesis" do
    ER2RB(<<DEFINE).should == 
if(flg) then
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
if(flg) then
  pass
else
  pass
end
DEFINE
  end

end

describe "unless expression case" do


  it "without parenthesis" do
    ER2RB(<<DEFINE).should == 
unless flg
  pass
DEFINE
    <<DEFINE.chomp!
unless flg
  pass
end
DEFINE
  end

  it "parenthesis" do
    ER2RB(<<DEFINE).should == 
unless(flg)
  pass
DEFINE
    <<DEFINE.chomp!
unless(flg)
  pass
end
DEFINE
  end

  it "then and without parenthesis" do
    ER2RB(<<DEFINE).should == 
unless flg then
  pass
DEFINE
    <<DEFINE.chomp!
unless flg then
  pass
end
DEFINE
  end

  it "then and parenthesis" do
    ER2RB(<<DEFINE).should == 
unless(flg) then
  pass
DEFINE
    <<DEFINE.chomp!
unless(flg) then
  pass
end
DEFINE
  end

  it "else and without parenthesis" do
    ER2RB(<<DEFINE).should == 
unless flg
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
unless flg
  pass
else
  pass
end
DEFINE
  end

  it "else and parenthesis" do
    ER2RB(<<DEFINE).should == 
unless(flg)
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
unless(flg)
  pass
else
  pass
end
DEFINE
  end

  it "else and then and without parenthesis" do
    ER2RB(<<DEFINE).should == 
unless flg then
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
unless flg then
  pass
else
  pass
end
DEFINE
  end

  it "else and then and parenthesis" do
    ER2RB(<<DEFINE).should == 
unless(flg) then
  pass
else
  pass
DEFINE
    <<DEFINE.chomp!
unless(flg) then
  pass
else
  pass
end
DEFINE
  end

end

describe "while expression case" do

  it "without parenthesis" do
    ER2RB(<<DEFINE).should == 
while flg
  pass
DEFINE
    <<DEFINE.chomp!
while flg
  pass
end
DEFINE
  end

  it "parenthesis" do
    ER2RB(<<DEFINE).should == 
while(flg)
  pass
DEFINE
    <<DEFINE.chomp!
while(flg)
  pass
end
DEFINE
  end
end

describe "until expression case" do

end
