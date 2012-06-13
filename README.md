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

```ruby
each {
  statements
}
```

Syntax of EndlessRuby’s “each do” case: 

```ruby
each do
  statements
```

**Require**:

Require the endless ruby source code on the Ruby implementation: 

```ruby
require 'homuhomu.er'
```

Or, you can omit extname ’.er’: 

```ruby
require 'homuhomu'
```

**Executing**:

Execute the endless ruby source code. 

    $ endlessruby homuhomu.er

**Compiling**:

Compile the endless ruby source code to the pure ruby source code. 

    $ endlessruby -c src/homuhomu.er -o lib

If -o option was appointed, EndlessRuby write to that directory. or else, EndlessRuby write to current directory. 

For example, this case, EndlessRuby write lib/homuhomu.rb from src/homuhomu.er that was compiled.

**Recursive compiling**: 

    $ endlessruby -rc src -o lib

If -r option was appointed, EndlessRuby recursive search that directory.

EndlessRuby compile each file whose extname is '.er', and write to the appointed directory by -o option, or directory whose source code is locateD.

And, EndlessRuby compile each file whose extname is ’.er’. For example, this case, EndlessRuby will write to: lib/homuhomu.rb if it is src/homuhomu.er, lib/homuhomu/example.rb if it is src/homuhomu/example.er. 

**Decompiling**:

Decompile ths pure ruby source code to the endless ruby source code. WARNING: this implementation is unstable version. 

    $ endlessruby -d lib/homuhomu.rb -o lib

Options is same usage as Compiling.

**Example**:

```ruby
[-2, -1, 0, 1, 2].reject do |x|
  x < 0
end.each do |n|
  puts n
```

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