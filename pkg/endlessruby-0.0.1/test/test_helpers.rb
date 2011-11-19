class TestEndlessRuby
  
  def test_blank_line
    assert_equal true, (blank_line? "        ")
  end

  def test_not_blank_line
    assert_equal false, (blank_line? "        pass")
  end


end
