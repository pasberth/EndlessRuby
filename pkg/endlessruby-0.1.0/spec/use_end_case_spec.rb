require File.dirname(__FILE__) + '/spec_helper.rb'

describe "use end case" do

  it "example" do
    ER2RB(<<DEFINE).should == 
def m
  if true
    case a
    when b then 1
    end
  else
  end
DEFINE
  <<DEFINE.chomp!
def m
  if true
    case a
    when b then 1
    end
  else
  end
end
DEFINE

  end
end
