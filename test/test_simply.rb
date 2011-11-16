class TestEndlessRuby
  
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

  def test_nest_keywords
    input_src = <<DEFINE
def test
  if false
    pass
  elsif true
    if true
      pass
    elsif false
      pass
    else
      pass
  else
    pass
DEFINE
    output_src = <<DEFINE
def test
  if false
    pass
  elsif true
    if true
      pass
    elsif false
      pass
    else
      pass
    end
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


  def test_5
    input_src = <<DEFINE
def method
  src = <<SRC
hello world
SRC
DEFINE
    output_src = <<DEFINE
def method
  src = <<SRC
hello world
SRC
end
DEFINE
    output_src.chomp!
    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)
  end

  def test_5_2
    input_src = <<DEFINE
def method
  src = <<-SRC
hello world
SRC
DEFINE
    output_src = <<DEFINE
def method
  src = <<-SRC
hello world
SRC
end
DEFINE
    output_src.chomp!
    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)
  end


  def test_commentout
    input_src = <<DEFINE
def method
  #TODO:
  # proc do
  #   statements 
DEFINE
    output_src = <<DEFINE
def method
  #TODO:
  # proc do
  #   statements 
end
DEFINE
    output_src.chomp!
    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)
  end

end
