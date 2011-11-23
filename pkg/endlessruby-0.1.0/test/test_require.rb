class TestEndlessRuby

  def test_require_without_er
    require "#{ROOT}/test/homu"
    assert_equal "hello", Homu.hello
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
