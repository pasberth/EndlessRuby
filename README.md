#EndlessRuby

If you use EndlessRuby, you can write source code without the use of 'end'.
You can just write (correctly indented) ruby minus the 'end's because EndlessRuby adds them in for you.

```ruby
class EndlessRubyWorld
  def self.hello!
    puts "hello!"
```

Be careful when using blocks. Use "each do" rather than "each {}".
You can not do ellipsis of '}' if you use "each {}"

Syntax of EndlessRuby's "each {}" case:

```ruby
each {
  statements
}
```

syntax of EndlessRuby's "each do" case:

```ruby
each do
  statements
```
##execute endless ruby source code:
	$ lib/endlessruby.rb example.er

##require endless ruby source code:

```ruby
require "path/to/endlessruby"
require "example.er"
```

##compile endless ruby source code to pure ruby.
	$ lib/endlessruby.rb -c example.er
	$ lib/endlessruby.rb -c src/example.er -o lib
-c option is compile and output to current directory from each arguments. arguments is filenames.
-o option appoint output directory.

#EndlessRuby Japanese README

EndlessRuby は Ruby のコードを end を使わずにインデントで表現できます

単に省略された end を補完することしかしないので、 end とインデント以外はピュアなRubyと同じように書けます。
endを省略しないこともできます。

```ruby
class EndlessRubyWorld
  def self.hello!
    puts "hello!"
```
ただ、複数行にまたがるブロックを渡す場合は

```ruby
each {
  statements
}
```
ではなく

```ruby
each do
  statements
```

を使ってください。もし each {} で渡すのなら、閉じカッコは省略できません  

##メソッドチェイン
```ruby
reject do |ary|
  ary.empty?
end.each do |ary|
  # statements
```

##endlessruby で書かれたソースを実行:
	$ lib/endlessruby.rb example.er

##endlessruby で書かれたソースをrequire
```ruby
require "path/to/endlessruby"
require "example.er"
```

##明示的にコンパイルしてピュアなRubyのソースに
	$ lib/endlessruby.rb -c example.er
	$ lib/endlessruby.rb -c src/example.er -o lib
-c オプションはその後渡されたすべての引数を、endlessrubyからpure rubyにコンパイルして、同じ名前.rbファイルをカレントディレクトリ以下の-oオプションのディレクトリに書き出します。もし-oが省略されたら、カレントディレクトリに書き出します。