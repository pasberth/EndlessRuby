ROOT = File.dirname(File.dirname(File.expand_path(__FILE__)))

require "test/unit"
require "#{ROOT}/lib/EndlessRuby"
class TestEndlessRuby < Test::Unit::TestCase
  
  include EndlessRuby
  
  def setup
  end

  def er2rb_right_output? want_output, input
    assert_equal want_output, ER2RB(input)
  end

  def test_ereval
    assert_equal "hello", ereval(<<ER)
"hello"
ER
  end

end

require "#{ROOT}/test/test_helpers"
require "#{ROOT}/test/test_simply"
require "#{ROOT}/test/test_require"
require "#{ROOT}/test/test_use_end_case"

