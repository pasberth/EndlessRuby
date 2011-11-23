require File.dirname(__FILE__) + '/spec_helper.rb'

describe "block exprs" do

  it "'case' expr" do
    ER2RB(<<DEFINE).should == 
res = case name
      when MANA then true
      else false
DEFINE
  <<DEFINE.chomp!
res = case name
      when MANA then true
      else false
      end
DEFINE
  end

end
