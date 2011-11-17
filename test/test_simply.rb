class TestEndlessRuby
  
  def test_1
    er2rb_right_output?(<<DEFINE.chomp!,
def test
  test
end
DEFINE
    <<DEFINE)
def test
  test
DEFINE
  end

  def test_2
    er2rb_right_output?(<<DEFINE.chomp!,
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
    <<DEFINE)
class Test
  def test
    proc do |args|
      pass
    proc do |args|
      pass
DEFINE
  end

  def test_3
    er2rb_right_output?(<<DEFINE.chomp!,
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
    <<DEFINE)
def test
  if false
    pass
  elsif true
    pass
  else
    pass
DEFINE
  end

  def test_nest_keywords
    er2rb_right_output?(<<DEFINE.chomp!,
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
    <<DEFINE)
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
  end

  def test_4
    er2rb_right_output?(<<DEFINE.chomp!,
def test
  if_nantoka
end
DEFINE
    <<DEFINE)
def test
  if_nantoka
DEFINE
  end


  def test_here_document
    er2rb_right_output?(<<DEFINE.chomp!,
def method
  src = <<SRC
hello world
SRC
end
DEFINE
    <<DEFINE)
def method
  src = <<SRC
hello world
SRC
DEFINE
  end

  def test_here_document2
    er2rb_right_output?(<<DEFINE.chomp!,
def method
  src = <<-SRC
hello world
SRC
end
DEFINE
    <<DEFINE)
def method
  src = <<-SRC
hello world
SRC
DEFINE
  end


  def test_commentout
    er2rb_right_output?(<<DEFINE.chomp!,
def method
  #TODO:
  # proc do
  #   statements 
end
DEFINE
    <<DEFINE)
def method
  #TODO:
  # proc do
  #   statements 
DEFINE
  end

end
