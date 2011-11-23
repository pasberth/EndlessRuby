#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'endlessruby/extensions'
require "tempfile"
require "irb"
require "kconv"

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
  VERSION = "0.1.0"

  extend self

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

  private
  def endless_ruby_to_pure_ruby_18 options
    flg = false
    opts = {}
    if options.respond_to? :to_hash
      opts = opts.merge options.to_hash
    elsif options.respond_to? :to_str
      io = Tempfile.new "endlessruby from temp file"
      io.write options.to_str
      io.seek 0
      opts[:io] = io
      flg = true
    elsif options.respond_to? :to_io
      opts[:io] = options.to_io
    end

    io = opts[:io]
    io.seek 0

    r = RubyLex.new
    r.set_input io
    r.skip_space = false

    pure = Tempfile.new "endlessruby pure temp file"

    indent = []
    pass = []
    bol = true
    bol_indent = 0

    while t = r.token

      if bol && !(RubyToken::TkSPACE === t) && !(RubyToken::TkNL === t)
          
        bol_indent = this_indent = t.char_no
        while indent.last && pass.last && this_indent <= indent.last && !pass.last.include?(t.class)
          _indent = indent.pop
          pass.pop
          idt = []
          loop do
            pure.seek pure.pos - 1
            break if pure.pos == 0 || !(["\n", " "].include?(c = pure.read(1)))
            pure.seek pure.pos - 1
            idt.unshift c
          end
          if idt.first == "\n"
            pure.write idt.shift
          end
          pure.write "#{' '*_indent}end\n"
          pure.write idt.join
        end
        bol = false
      end

      case t
      when RubyToken::TkNL
        bol = true
      when RubyToken::TkEND
        indent.pop
        pass.pop
      when RubyToken::TkIF, RubyToken::TkUNLESS
        pass << [RubyToken::TkELSE, RubyToken::TkELSIF]
        indent << t.char_no
      when RubyToken::TkWHILE, RubyToken::TkUNTIL
        pass << []
        indent << t.char_no
      when RubyToken::TkBEGIN
        pass << [RubyToken::TkRESCUE, RubyToken::TkELSE, RubyToken::TkENSURE]
        indent << t.char_no
      when RubyToken::TkDEF
        pass << [RubyToken::TkRESCUE, RubyToken::TkELSE, RubyToken::TkENSURE]
        indent << t.char_no
      when RubyToken::TkCLASS, RubyToken::TkMODULE
        pass << []
        indent << t.char_no
      when RubyToken::TkCASE
        pass << [RubyToken::TkWHEN, RubyToken::TkELSE]
        indent << t.char_no
      when RubyToken::TkDO
        pass << []
        indent << bol_indent
      when RubyToken::TkSPACE
      end

      pos = io.pos
      io.seek t.seek
      pure.write io.read(r.seek - t.seek)
      io.seek pos
    end

    until indent.empty? && pass.empty?
      _indent = indent.pop
      pass.pop
      pure.write "#{' '*_indent}end\n"
    end

    io.close if flg
    pure.seek 0
    pure.read.chomp
  end

  def endless_ruby_to_pure_ruby_19 options
    flg = false
    opts = {}
    if options.respond_to? :to_hash
      opts = opts.merge options.to_hash
    elsif options.respond_to? :to_str
      io = Tempfile.new "endlessruby from temp file"
      # io.set_encoding 'UTF-8', 'UTF-8'
      io.write options.to_str
      io.seek 0
      opts[:io] = io
      flg = true
    elsif options.respond_to? :to_io
      opts[:io] = options.to_io
    end

    io = opts[:io]
    io.seek 0

    r = RubyLex.new
    r.set_input io
    r.skip_space = false

    pure = Tempfile.new "endlessruby pure temp file"
    # pure.set_encoding 'UTF-8', 'UTF-8'

    indent = []
    pass = []
    bol = true
    last = [0, 0]
    bol_indent = 0

    while t = r.token

      if bol && !(RubyToken::TkSPACE === t) && !(RubyToken::TkNL === t)
          
        bol_indent = this_indent = t.char_no
        while indent.last && pass.last && this_indent <= indent.last && !pass.last.include?(t.class)
          _indent = indent.pop
          pass.pop
          idt = []
          loop do
            pure.seek pure.pos - 1
            break if pure.pos == 0 || !(["\n", ' '].include?(c = pure.getc))
            pure.seek pure.pos - 1
            idt.unshift c
          end
          if idt.first == "\n"
            pure.write idt.shift
          end
          pure.write "#{' '*_indent}end\n"
          pure.write idt.join
        end
        bol = false
      end

      case t
      when RubyToken::TkNL
        bol = true
      when RubyToken::TkEND
        indent.pop
        pass.pop
      when RubyToken::TkIF, RubyToken::TkUNLESS
        pass << [RubyToken::TkELSE, RubyToken::TkELSIF]
        indent << t.char_no
      when RubyToken::TkWHILE, RubyToken::TkUNTIL
        pass << []
        indent << t.char_no
      when RubyToken::TkBEGIN
        pass << [RubyToken::TkRESCUE, RubyToken::TkELSE, RubyToken::TkENSURE]
        indent << t.char_no
      when RubyToken::TkDEF
        pass << [RubyToken::TkRESCUE, RubyToken::TkELSE, RubyToken::TkENSURE]
        indent << t.char_no
      when RubyToken::TkCLASS, RubyToken::TkMODULE
        pass << []
        indent << t.char_no
      when RubyToken::TkCASE
        pass << [RubyToken::TkWHEN, RubyToken::TkELSE]
        indent << t.char_no
      when RubyToken::TkDO
        pass << []
        indent << bol_indent
      when RubyToken::TkSPACE
      end

      pos = io.pos
      io.seek last[0]
      (r.seek - last[1]).times do
        pure.write io.getc
      end
      last = [io.pos, r.seek]
      io.seek pos
    end

    until indent.empty? && pass.empty?
      _indent = indent.pop
      pass.pop
      pure.write "#{' '*_indent}end\n"
    end

    io.close if flg
    pure.seek 0
    pure.read.chomp
  end

  public
  # EndlessRubyの構文をピュアなRubyの構文に変換します。
  def endless_ruby_to_pure_ruby options
    if RUBY_VERSION < "1.9" # 1.8
      endless_ruby_to_pure_ruby_18 options
    else
      endless_ruby_to_pure_ruby_19 options
    end
  end

  alias to_pure_ruby endless_ruby_to_pure_ruby
  alias ER2PR endless_ruby_to_pure_ruby
  alias ER2RB endless_ruby_to_pure_ruby
end

if __FILE__ == $PROGRAM_NAME
  require 'endlessruby/main'
  EndlessRuby::Main.main ARGV
end