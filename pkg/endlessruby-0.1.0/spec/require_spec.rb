require File.dirname(__FILE__) + '/spec_helper.rb'

describe "require" do

  it "require the file" do
    require 'test_data/file.er'
    $test_data.should == "file"
    TestData.test_data.should == "file"
  end

  it "require the 'er' omission file" do
    require 'test_data/er_omission'
    $test_data.should == "er omission"
    TestData.test_data.should == "er omission"
  end

  it "require the ruby script 'rb' omission" do
    require 'test_data/rb_omission'
    $test_data.should == "rb omission"
    TestData.test_data.should == "rb omission"
  end

  it "require the ruby script" do
    require 'test_data/ruby_script.rb'
    $test_data.should == "ruby script"
    TestData.test_data.should == "ruby script"
  end

  it "require ellipsis of 'er' and exist same name directory" do

    require 'test_data/exist_same_name_directory'

    $test_data.should == "exist same name directory"
    TestData.test_data.should == "exist same name directory"
  end

end
