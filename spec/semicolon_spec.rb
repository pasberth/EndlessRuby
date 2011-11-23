require File.dirname(__FILE__) + '/spec_helper.rb'

describe "split with semicolon lines is inner lines" do

  it "example" do
    ER2RB(<<DEFINE).should == 
def method; statements; end
DEFINE
  <<DEFINE.chomp!
def method; statements; end
DEFINE

  end

  it "example" do
    ER2RB(<<DEFINE).should == 
def method; statements
DEFINE
  <<DEFINE.chomp!
def method; statements
end
DEFINE

  end

end
