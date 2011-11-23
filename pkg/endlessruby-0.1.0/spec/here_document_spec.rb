require File.dirname(__FILE__) + '/spec_helper.rb'

describe "here document case" do

  it "CASE 1" do
    ER2RB(<<DEFINE).should == 
def method
  src = <<SRC
hello world
SRC
DEFINE
  <<DEFINE.chomp!
def method
  src = <<SRC
hello world
SRC
end
DEFINE
  end

  it "CASE 2" do
    ER2RB(<<DEFINE).should == 
def method
  src = <<-SRC
hello world
  SRC
def method2
  pass
DEFINE
  <<DEFINE.chomp!
def method
  src = <<-SRC
hello world
  SRC
end
def method2
  pass
end
DEFINE
  end

  it "CASE 3" do
    ER2RB(<<DEFINE).should == 
def method
  src = <<SRC
hello world
  SRC
SRC
DEFINE
  <<DEFINE.chomp!
def method
  src = <<SRC
hello world
  SRC
SRC
end
DEFINE
  end

end
