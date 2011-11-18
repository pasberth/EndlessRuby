describe "comment out case" do

  it "comment" do
    ER2RB(<<DEFINE).should == 
#TODO:
# proc do |item|
#   statements
DEFINE
    <<DEFINE.chomp!
#TODO:
# proc do |item|
#   statements
DEFINE
  end

  it "simple comment" do
    ER2RB(<<DEFINE).should == 
#TODO:
# proc do |item|
#   statements
DEFINE
    <<DEFINE.chomp!
#TODO:
# proc do |item|
#   statements
DEFINE
  end

end

describe "rdoc case" do

  it "rerurned" do
    ER2RB(<<DEFINE).should == 
# DOCUMENT LINE 1
# DOCUMENT LINE 2
def method1
  statements
  return
# DOCUMENT LINE 1
# DOCUMENT LINE 2
def method1
  statements
  return
DEFINE
    <<DEFINE.chomp!
# DOCUMENT LINE 1
# DOCUMENT LINE 2
def method1
  statements
  return
end
# DOCUMENT LINE 1
# DOCUMENT LINE 2
def method1
  statements
  return
end
DEFINE
  end

end
