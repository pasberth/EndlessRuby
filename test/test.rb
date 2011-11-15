ROOT = File.dirname(File.dirname(File.expand_path(__FILE__)))

require "test/unit"
require "#{ROOT}/lib/EndlessRuby"
class TestEndlessRuby < Test::Unit::TestCase
  
  include EndlessRuby
  
  def setup
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

