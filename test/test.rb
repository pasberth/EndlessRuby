ROOT = File.dirname(File.dirname(File.expand_path(__FILE__)))

require "test/unit"
require "#{ROOT}/lib/EndlessRuby"

class TestEndlessRuby < Test::Unit::TestCase
  
  include EndlessRuby
  
  def setup
  end
  
  def test_blank_line
    assert_equal true, (blank_line? "        ")
  end

  def test_not_blank_line
    assert_equal false, (blank_line? "        pass")
  end
  
  def test_1
    input_src = <<DEFINE
def test
  test
DEFINE
    output_src = <<DEFINE
def test
  test
end
DEFINE
    output_src.chomp!
    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)
  end

  def test_2
    input_src = <<DEFINE
class Test
  def test
    proc do |args|
      pass
    proc do |args|
      pass
DEFINE
    output_src = <<DEFINE
class Test
  def test
    proc do |args|
      pass
    end
    proc do |args|
      pass
    end
  end
end
DEFINE
    output_src.chomp!
    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)
  end

  def test_3
    input_src = <<DEFINE
def test
  if false
    pass
  elsif true
    pass
  else
    pass
DEFINE
    output_src = <<DEFINE
def test
  if false
    pass
  elsif true
    pass
  else
    pass
  end
end
DEFINE
    output_src.chomp!
    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)
  end

  def test_4
    input_src = <<DEFINE
def test
  if_nantoka
DEFINE
    output_src = <<DEFINE
def test
  if_nantoka
end
DEFINE
    output_src.chomp!
    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)
  end

  def test_require
    require "#{ROOT}/test/foo.er"
    assert_equal "hello", Foo.hello
  end

  def test_load_path
    $LOAD_PATH << "#{ROOT}/test"
    require "bar.er"
    assert_equal "hello", Bar.hello
  end

  def test_ereval
    assert_equal "hello", ereval(<<ER)
"hello"
ER
  end

  def test_is_a_dir
    assert_raise(LoadError) {
      require "#{ROOT}/test/is_a_dir"
    }  
  end

  def test_no_such_file
    assert_raise(LoadError) {
      require "#{ROOT}/test/no_such_file"
    }
  end

end
