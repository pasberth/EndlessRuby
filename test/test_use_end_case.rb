class TestEndlessRuby
  

  def test_method_chain_case

    er2rb_right_output?(<<DEFINE.chomp!,
def test
  self.map do |item|
    pass
  end.each do |item|
    pass
  end
end
DEFINE
    <<DEFINE)
def test
  self.map do |item|
    pass
  end.each do |item|
    pass
DEFINE

  end

  def test_use_end_case
    er2rb_right_output?(<<DEFINE.chomp!,
def test
  self.map do |item|
  end
end
DEFINE
    <<DEFINE)
def test
  self.map do |item|
  end
end
DEFINE
  end

  def test_beggining_of_the_end_function
    er2rb_right_output?(<<DEFINE.chomp!,
def test
  self.each do |item|
    pass
  endlessruby src
end
DEFINE
    <<DEFINE)
def test
  self.each do |item|
    pass
  end
  endlessruby src
end
DEFINE
  end

end
