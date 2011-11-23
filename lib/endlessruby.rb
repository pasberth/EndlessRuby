#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'endlessruby/custom_require'
require "tempfile"
require "fileutils"
require "irb"

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
    eval(ER2PR(src), binding, filename, lineno)
  end

  # EndlessRubyの構文をピュアなRubyの構文に変換します。
  # options: オプションを表すHashまたはto_hashを実装したオブジェクト、構文を読み出すIOまたはto_ioを実装したオブジェクト、EndlessRubyの構文を表すStringまたはto_strを実装したオブジェクト
  # optionsが文字列ならばそれをピュアなRubyの構文にします。それがIOならばIOから読み出してそれをピュアなRubyの構文にします。
  # それがHashならば、現在のところinとoutを指定できます。それぞれHashを指定します。opts[:in][:io]はoptionsに指定するIOと同じ意味です。
  # opts[:out][:io] には書き出すioを指定します。
  def endless_ruby_to_pure_ruby options
    converting_helper options
  end

  alias to_pure_ruby endless_ruby_to_pure_ruby
  alias ER2PR endless_ruby_to_pure_ruby
  alias ER2RB endless_ruby_to_pure_ruby

  # Rubyの構文をEndlessRubyの構文に変換します。
  def pure_ruby_to_endless_ruby options
    options = merge_options options
    options[:decompile] = true
    converting_helper options
  end

  alias RB2ER pure_ruby_to_endless_ruby
  alias PR2ER pure_ruby_to_endless_ruby

  private

  def merge_options options

    opts = {
      :in => {}, :out => {}
    }

    if options.respond_to? :to_hash
      return options if options.to_hash[:merged]
      opts = opts.merge options.to_hash
    elsif options.respond_to?(:to_io) || options.respond_to?(:to_str)
      opts[:in][:any] = options
    else
      raise ArgumentError, "options is IO, String, or Hash"
    end

    if opts[:in][:any]
      if opts[:in][:any].respond_to?(:to_str) && File.exist?(opts[:in][:any].to_str) # from a file on the disk.
        opts[:in] = {
          :io => (in_io = open opts[:in][:any].to_str),
          :ensure => proc { in_io.close }
        }
      elsif opts[:in][:any].respond_to? :to_io # from IO that can read source code.
        opts[:in] = {
          :io => options.to_io,
          :ensure => proc {}
        }
      elsif opts[:in][:any].respond_to? :to_str # from String that is source code.
        in_io = Tempfile.new "endlessruby from temp file"
        in_io.write options.to_str
        in_io.seek 0
        opts[:in] = {
          :io => in_io,
          :ensure => proc { in_io.close }
        }
      else
        raise ArgumentError, "options[:in][:any] is IO, String which is path, or String which is source code"
      end
    end

    opts[:in][:any] = nil

    if opts[:out][:any]
      if opts[:out][:any].respond_to?(:to_str) # to a file on the disk.
        opts[:out] = {
          :io => (out_io = open opts[:out][:any].to_str, "w+"),
          :ensure => proc { out_io.close }
        }
      elsif opts[:out][:any].respond_to? :to_io # to IO that can read source code.
        opts[:out] = {
          :io => options.to_io,
          :ensure => proc {}
        }
      else
        raise ArgumentError, "options[:out][:any] is IO, or String which is Path"
      end
    else
      opts[:out] = { :io => (out_io = Tempfile.new("endlessruby pure temp file")), :ensure => proc { out_io.close } }
    end

    opts[:out][:any] = nil

    opts[:merged] = true
    opts
  end

  def converting_helper options
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
        if opts[:decompile]
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

    until opts[:decompile] || (indent.empty? && pass.empty?)
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

    opts[:out][:ensure] && opts[:out][:ensure].call
    opts[:in][:ensure] && opts[:in][:ensure].call

    ret.chomp
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'endlessruby/main'
  EndlessRuby::Main.main ARGV
end