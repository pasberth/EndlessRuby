class TestEndlessRuby
  

  def test_use_end_case

    input_src = <<DEFINE
def test
  self.map do |item|
    pass
  end.each do |item|
    pass

DEFINE
    output_src = <<DEFINE
def test
  self.map do |item|
    pass
  end.each do |item|
    pass
  end
end
DEFINE
    output_src.chomp!

    assert_equal output_src, (endless_ruby_to_pure_ruby input_src)

  end

end
