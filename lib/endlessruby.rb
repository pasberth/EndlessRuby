#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'endlessruby/extensions'
module EndlessRuby
  VERSION = "0.0.1"
  extend self
  private
  def blank_line? line
    return true unless line
    (line.chomp.gsub /\s+?/, '') == ""
  end
  def unindent line
    line  =~ /^\s*?(\S.*?)$/
    $1
  end
  def indent line, level, indent="  "
    "#{indent * level}#{line}"
  end
  def indent_count line, indent="  "
    return 0 unless line
    if line =~ /^#{indent}(.*?)$/
      1 + (indent_count $1, indent)
    else
      0
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
    [/^begin(?:$|\s+)/, /^rescue(:?\s|\().*?$/, /^else(?:$|\s+)/, /^ensure(?:$|\s+)/],
    [/^.*?\s+do(:?$|\s|\|)/]
  ]
  public
  def ereval(src, binding=TOPLEVEL_BINDING, filename=__FILE__, lineno=1)
    at = caller
    eval(ER2PR(src), binding, filename, lineno)
  rescue Exception => e
    $@ = at
    raise e
  end
  def ercompile(er, rb)
    open(er) do |erfile|
      open(rb, "w") do |rbfile|
        rbfile.write(endless_ruby_to_pure_ruby(erfile.read))
      end
    end
  end
  def endless_ruby_to_pure_ruby src
    endless = src.split "\n"
    endless.reject! { |line| blank_line? line }
    pure = []
    i = 0
    while i < endless.length
      pure += [(currently_line = endless[i])]
      # ブロックを作らない構文なら単に無視する 
      next i += 1 unless BLOCK_KEYWORDS.any? { |k| k[0] =~ unindent(currently_line)  }
      keyword = BLOCK_KEYWORDS.each { |k| break k if k[0] =~ unindent(currently_line)  }
      currently_indent_depth = indent_count currently_line
      just_after_indent_depth = indent_count endless[i + 1]
      if currently_indent_depth < just_after_indent_depth || keyword[1..-1].any? { |k| k =~ unindent(endless[i + 1]) }
        base_indent_depth = currently_indent_depth
        inner_statements = []
        while i < endless.length
          if base_indent_depth > indent_count(endless[i + 1])
            break
          end
          if base_indent_depth == indent_count(endless[i + 1])
            unless keyword[1..-1].any? { |k| k =~ unindent(endless[i + 1]) }
              break
            end
          end
          inner_statements << endless[i + 1]
          i += 1
        end
        pure += endless_ruby_to_pure_ruby(inner_statements.join("\n")).split "\n"
      end
      # 次の行がendならばendを補完しない(ワンライナーのため)
      unless endless[i + 1] =~ /^\s*end.*$/
        pure += ["#{'  '*currently_indent_depth}end"]
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