require File.dirname(__FILE__) + '/spec_helper.rb'

describe "concrete examples" do

  spec = File.dirname(__FILE__)
  examples = %w[
    concrete_examples/case_1_simply_test_case
  ]

  examples.each do |_case|
    begin
      er = open File.join(spec, "#{_case}.er")
      rb = open File.join(spec, "#{_case}.rb")
      rb_s = ERSpecHelper.chomp rb.read
      er_s = er.read
      it "must can compile #{_case}.er to #{_case}.rb" do
        ER2RB(er_s).should == rb_s
      end
    ensure
      er.close
      rb.close
    end
  end

end

describe "discover bugs from concrete examples" do

  it "the bug reappear when that contains spaces for the next end from the last breaking indentation" do
  ER2RB(<<DEFINE).should ==
class TestEndlessRuby < Test::Unit::TestCase
  
  include EndlessRuby
  
  def setup
  end

end
DEFINE
  <<DEFINE.chomp!
class TestEndlessRuby < Test::Unit::TestCase
  
  include EndlessRuby
  
  def setup
  end

end
DEFINE

  end

end
