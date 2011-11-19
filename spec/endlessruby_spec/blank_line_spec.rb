describe "blank lines" do

  it "blank line ending" do
    ER2RB(<<DEFINE).should == 
module Kenel
  def method1
    statements

    return
DEFINE
    <<DEFINE.chomp!
module Kenel
  def method1
    statements

    return
  end
end
DEFINE
  end

end
