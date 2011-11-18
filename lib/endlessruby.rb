#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'endlessruby/extensions'

# EndlessRubyはRubyをendを取り除いて書けます。
#
# Usage:
#    
# erファイルをrequire
#    require 'homuhomu.er' | require 'homuhomu'
#
# erファイルを実行
#    $ path/to/endlessruby.rb homuhomu.er
#
# erファイルをコンパイル
#    $ path/to/endlessruby.rb -c src/homuhomu.er -o lib
# # => src/homuhomu.er をコンパイルして lib/homuhomu.rb を書き出します。
# #  -o が省略された場合はカレントディレクトリに書き出します。
#
# Example:
# class EndlessRubyWorld
#
#   def self.hello!
#     puts "hello!"
#
#
# [-2, -1, 0, 1, 2].reject do |x|
#   x < 0
# end.each do |n|
#   puts n
#
#   そのほかは/examplesを読んでください
module EndlessRuby

  # EndlessRuby の場＾ジョンです
  VERSION = "0.0.1"

  extend self

  private

  # 内部で使用します。空業かどうか判定します。
  def blank_line? line
    return true unless line
    (line.chomp.gsub /\s+?/, '') == ""

  # 内部で使用します。インデントを取り除きます
  end
  def unindent line
    line  =~ /^\s*?(\S.*?)$/
    $1
  # 内部で使用します。インデントします
  end
  def indent line, level, indent="  "
    "#{indent * level}#{line}"

  # 内部で使用します。インデントの数を数えます。
  end
  def indent_count line, indent="  "
    return 0 unless line
    if line =~ /^#{indent}(.*?)$/
      1 + (indent_count $1, indent)
    else
      0

  # 内部で使用します。ブロックを作るキーワード群です。
    end
  end
  BLOCK_KEYWORDS = [
    [/^if(:?\s|\().*?$/, /^elsif(:?\s|\().*?$/, /^else(?:$|\s+)/],
    [/^unless(:?\s|\().*?$/, /^elsif(:?\s|\().*?$/, /^else(?:$|\s+)/],
    [/^while(:?\s|\().*?$/],
    [/^until(:?\s|\().*?$/],
    [/^case(:?\s|\().*?$/, /^when(:?\s|\().*?$/, /^else(?:$|\s+)/],
    [/^def\s.*?$/, /^rescue(:?\s|\().*?$/, /^else(?:$|\s+)/, /^ensure(?:$|\s+)/],
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

  # 廃止予定です
  end
  def ercompile(er, rb)
    open(er) do |erfile|
      open(rb, "w") do |rbfile|
        rbfile.write(endless_ruby_to_pure_ruby(erfile.read))

  # EndlessRubyの構文をピュアなRubyの構文に変換します。
      end
    end
  end
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

      # ブロックを作らない構文なら単に無視する 
      end
      next i += 1 unless BLOCK_KEYWORDS.any? { |k| k[0] =~ unindent(currently_line)  }

      # ブロックに入る
      keyword = BLOCK_KEYWORDS.each { |k| break k if k[0] =~ unindent(currently_line)  }

      currently_indent_depth = indent_count currently_line
      base_indent_depth = currently_indent_depth

      inner_statements = []
      in_here_document = nil
      while i < endless.length

        inner_currently_line = endless[i + 1]

        if inner_currently_line =~ /(.*)(?:^|(?:(?!\\).))\#(?!\{).*$/
            inner_currently_line = $1
        end
        if blank_line? inner_currently_line
          inner_statements << endless[i + 1]
          i += 1
          next
        end
        just_after_indent_depth = indent_count inner_currently_line

        if in_here_document
          if inner_currently_line =~ /^#{in_here_document}\s*$/
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
        if inner_currently_line =~ /^.*?\<\<\-?(\w+)(?!\w).*$/
          in_here_document = $1
          
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
      pure += ER2PR(inner_statements.join("\n")).split "\n"
      # 次の行がendならばendを補完しない(ワンライナーのため)
      unless endless[i + 1] && endless[i + 1] =~ /^\s*end(?!\w).*$/
        pure << "#{'  '*currently_indent_depth}end"
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