#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'endlessruby/extensions'

# EndlessRubyはRubyをendを取り除いて書けます。
#
# erファイルをrequire
#   require 'homuhomu.er' | require 'homuhomu'
#
# erファイルを実行
#   $ path/to/endlessruby.rb homuhomu.er
#
# erファイルをコンパイル
#   $ path/to/endlessruby.rb -c src/homuhomu.er -o lib
#   # => src/homuhomu.er をコンパイルして lib/homuhomu.rb を書き出します。
#   #  -o が省略された場合はカレントディレクトリに書き出します。
#
# Example:
#   class EndlessRubyWorld
#
#     def self.hello!
#       puts "hello!"
#
#
#   [-2, -1, 0, 1, 2].reject do |x|
#     x < 0
#   end.each do |n|
#     puts n
#
module EndlessRuby

  # EndlessRuby のバージョンです
  VERSION = "0.0.1"

  extend self

  private

  # 内部で使用します。空業かどうか判定します。
  def blank_line? line
    return true unless line
    (line.chomp.gsub /\s+?/, '') == ""
  end

  # 内部で使用します。インデントを取り除きます
  def unindent line
    line  =~ /^\s*?(\S.*?)$/
    $1
  end
  # 内部で使用します。インデントします
  def indent line, level, indent="  "
    "#{indent * level}#{line}"
  end

  # 内部で使用します。インデントの数を数えます。
  def indent_count line, indent="  "
    return 0 unless line
    if line =~ /^#{indent}(.*?)$/
      1 + (indent_count $1, indent)
    else
      0
    end
  end

  # 内部で使用します。ブロックを作るキーワード群です。
  BLOCK_KEYWORDS = [
    [/^if(:?\s|\().*?$/, /^elsif(:?\s|\().*?$/, /^else(?:$|\s+)/],
    [/^unless(:?\s|\().*?$/, /^elsif(:?\s|\().*?$/, /^else(?:$|\s+)/],
    [/^while(:?\s|\().*?$/],
    [/^until(:?\s|\().*?$/],
    [/^case(:?\s|\().*?$/, /^when(:?\s|\().*?$/, /^else(?:$|\s+)/],
    [/^def\s.*?$/, /^rescue(:?$|\s|\().*?$/, /^else(?:$|\s+)/, /^ensure(?:$|\s+)/],
    [/^class\s.*?$/],
    [/^module\s.*?$/],
    [/^begin(?:$|\s+)/, /^rescue(:?$|\s|\().*?$/, /^else(?:$|\s+)/, /^ensure(?:$|\s+)/],
    [/^.*?\s+do(:?$|\s|\|)/]
  ]

  public

  # 文字列をEndlessRubyの構文として実行します。引数の意味はKernel#evalと同じです
  def ereval(src, binding=TOPLEVEL_BINDING, filename=__FILE__, lineno=1)
    at = caller
    eval(ER2PR(src), binding, filename, lineno)
  rescue Exception => e
    $@ = at
    raise e
  end

  # Rubyの構文をEndlessRubyの構文に変換します。
  def pure_ruby_to_endless_ruby src
    @decompile = true
    s = ER2RB(src)
    @decompile = nil
    s
  end


  alias RB2ER pure_ruby_to_endless_ruby
  alias PR2ER pure_ruby_to_endless_ruby

  # EndlessRubyの構文をピュアなRubyの構文に変換します。
  def endless_ruby_to_pure_ruby src
    endless = src.split "\n"

    pure = []
    i = 0
    while i < endless.length
      pure << (currently_line = endless[i])

      if currently_line =~ /(.*)(?:^|(?:(?!\\).))\#(?!\{).*$/
        currently_line = $1
      end

      if blank_line? currently_line
        i += 1
        next
      end

      # ブロックを作らない構文なら単に無視する 
      next i += 1 unless BLOCK_KEYWORDS.any? { |k| k[0] =~ unindent(currently_line)  }

      # ブロックに入る
      keyword = BLOCK_KEYWORDS.each { |k| break k if k[0] =~ unindent(currently_line)  }

      currently_indent_depth = indent_count currently_line
      base_indent_depth = currently_indent_depth

      inner_statements = []
      # def method1
      #   statemetns
      # # document of method2
      # def method2
      #   statements
      # のような場合にコメントの部分はmethod1内に含まないようにする。
      # def method1
      #   statemetns
      # # comment
      #   return
      # のような場合と区別するため。
      comment_count = 0
      in_here_document = nil
      while i < endless.length

        inner_currently_line = endless[i + 1]

        if inner_currently_line =~ /(.*)(?:^|(?:(?!\\).))\#(?!\{).*$/
          if blank_line?($1) && currently_indent_depth >= indent_count(inner_currently_line)
            comment_count += 1
          end
          inner_currently_line = $1
        elsif blank_line? inner_currently_line
          comment_count += 1
        end

        if blank_line? inner_currently_line
          inner_statements << endless[i + 1]
          i += 1
          next
        end

        just_after_indent_depth = indent_count inner_currently_line

        # 次の行がendならば意図のあるものなのでendを持ちあ揚げない
        if inner_currently_line =~ /^\s*end(?!\w).*$/
          comment_count = 0
        end

        if base_indent_depth < just_after_indent_depth
          comment_count = 0
        end

        if in_here_document
          if (in_here_document[0] == '' && inner_currently_line =~ /^#{in_here_document[1]}\s*$/) || # <<DEFINE case
              (in_here_document[0] == '-' && inner_currently_line =~ /^\s*#{in_here_document[1]}\s*$/) # <<-DEFINE case
            in_here_document = nil
            inner_statements << endless[i + 1]
            i += 1
            next
          else
            inner_statements << endless[i + 1]
            i += 1
            next
          end
        end

        if inner_currently_line =~ /^.*?\<\<(\-?)(\w+)(?!\w).*$/
          in_here_document = [$1, $2]
        end

        if base_indent_depth > indent_count(inner_currently_line)
          break
        end

        if base_indent_depth == indent_count(inner_currently_line)
          unless keyword[1..-1].any? { |k| k =~ unindent(inner_currently_line) }
            break
          end
        end

        inner_statements << endless[i + 1]
        i += 1
      end

      # endをコメントより上の行へ持ち上げる
      if 0 < comment_count
        comment_count.times do
          inner_statements.pop
        end
        i -= comment_count
      end

      pure += ER2PR(inner_statements.join("\n")).split "\n"
      # 次の行がendならばendを補完しない(ワンライナーのため)
      unless @decompile
        unless endless[i + 1] && endless[i + 1] =~ /^\s*end(?!\w).*$/
          pure << "#{'  '*currently_indent_depth}end"
        end
      else
        # メソッドチェインは削除しない
        if endless[i + 1] && endless[i + 1] =~ /^\s*end(?:\s|$)\s*$/
          i += 1
        end
      end

      i += 1
    end
    pure.join "\n"
  end

  alias to_pure_ruby endless_ruby_to_pure_ruby
  alias ER2PR endless_ruby_to_pure_ruby
  alias ER2RB endless_ruby_to_pure_ruby
end

if __FILE__ == $PROGRAM_NAME
  require 'endlessruby/main'
  EndlessRuby::Main.main ARGV
end