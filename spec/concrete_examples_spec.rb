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
