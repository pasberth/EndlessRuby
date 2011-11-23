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
  def pure_ruby_to_endless_ruby options
    @decompile = true
    s = ER2RB(options)
    @decompile = nil
    s
  end


  alias RB2ER pure_ruby_to_endless_ruby
  alias PR2ER pure_ruby_to_endless_ruby

  private
  def merge_options options
    opts = {
      :out => { :io => Tempfile.new("endlessruby pure temp file"), :ensure => proc { opts[:out][:io].close } }
    }

    if options.respond_to? :to_hash
      opts = opts.merge options.to_hash
    elsif options.respond_to? :to_str
      # 文字列を指定された場合はその文字列をパースする
      io = Tempfile.new "endlessruby from temp file"
      io.write options.to_str
      io.seek 0
      opts[:in] = {
        :io => io,
        :ensure => proc { io.close }
      }

    elsif options.respond_to? :to_io
      opts[:in] = {
        :io => options.to_io,
        :ensure => proc {}
      }
    else
      fail
    end

    opts
  end

  public
  # EndlessRubyの構文をピュアなRubyの構文に変換します。
  def endless_ruby_to_pure_ruby options
    opts = merge_options options

    io = opts[:in][:io]

    r = RubyLex.new
    r.set_input io
    r.skip_space = false

    pure = opts[:out][:io]

    indent = []
    pass = []
    bol = true
    last = [0, 0]
    bol_indent = 0

    while t = r.token

      if bol && !(RubyToken::TkSPACE === t) && !(RubyToken::TkNL === t)

        bol_indent = this_indent = t.char_no
        while indent.last && pass.last && this_indent <= indent.last && !pass.last.include?(t.class)
          if RubyToken::TkEND === t && this_indent == indent.last
            indent.pop
            pass.pop
            next
          end

          _indent = indent.pop
          pass.pop
          idt = []
          loop do
            pure.seek pure.pos - 1
            if RUBY_VERSION < "1.9" # 1.8
              c = pure.read(1)
            else
              c = pure.getc
            end
            break if pure.pos == 0 || !(["\n", ' '].include?(c))
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
        if @decompile
          last[0] += 3
          last[1] += 3
          next
        end
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
      io.seek pos

      pos = io.pos

      if RUBY_VERSION < "1.9" # 1.8
        io.seek t.seek
        pure.write io.read(r.seek - t.seek)
      else # 1.9
        io.seek last[0]
        (r.seek - last[1]).times do
          pure.write io.getc
        end
        last = [io.pos, r.seek]
      end

      io.seek pos
    end

    until @decompile || (indent.empty? && pass.empty?)
      _indent = indent.pop
      pass.pop
      pure.seek pure.pos - 1
      if RUBY_VERSION < "1.9" # 1.8
        c = pure.read 1
      else
        c = pure.getc
      end
      if c  == "\n"
        pure.write "#{' '*_indent}end"
      else
        pure.write "\n#{' '*_indent}end"
      end
    end

    pure.seek 0
    ret = pure.read.chomp
    pure.seek 0

    opts[:out][:ensure].call
    opts[:in][:ensure].call

    ret
  end

  alias to_pure_ruby endless_ruby_to_pure_ruby
  alias ER2PR endless_ruby_to_pure_ruby
  alias ER2RB endless_ruby_to_pure_ruby
end

if __FILE__ == $PROGRAM_NAME
  require 'endlessruby/main'
  EndlessRuby::Main.main ARGV
end