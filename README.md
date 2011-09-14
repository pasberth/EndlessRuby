#EndlessRuby
EndlessRuby は Ruby のコードを end を使わずにインデントで表現できます

単に省略された end を補完することしかしないので、 end とインデント以外はピュアなRubyと同じように書けます。

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