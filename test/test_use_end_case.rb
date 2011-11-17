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

end
