#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
module Kernel
  alias endlessruby_original_require require
  def require path
    at = caller
    endlessruby_original_require path
  rescue Exception
    case path
    when /^\.\/.*?$/, /^\/.*?$/
      unless File.exist? path
        $@ = at
        raise LoadError, "no such file to load -- #{path}"
      end
      if File.directory? path
        $@ = at
        raise LoadError, "Is a directory - #{path}"
      end
      open(path) do |file|
        begin
          TOPLEVEL_BINDING.eval EndlessRuby.to_pure_ruby(file.read), File.expand_path(path)
        rescue Exception => e
          $@ = at
          raise e
        end
        return true
      end
    else
      is_that_dir = false
      $LOAD_PATH.each do |load_path|
        real_path = File.join load_path, path
        next unless File.exist? real_path
        next is_that_dir = true if File.directory? real_path
        open(real_path) do |file|
          begin
            TOPLEVEL_BINDING.eval EndlessRuby.to_pure_ruby(file.read), File.expand_path(real_path)
          rescue Exception => e
            $@ = at
            raise e
          end
        end
        return true
      end
      $@ = at
      if is_that_dir
        raise LoadError, "Is a directory - #{path}"
      else
        raise LoadError, "no such file to load -- #{path}"
      end
    end
  end
end
module EndlessRuby
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
  def ereval(src, binding=TOPLEVEL_BINDING)
    binding.eval(endless_ruby_to_pure_ruby src)
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
      " ブロックを作らない構文なら単に無視する "
      next i += 1 unless BLOCK_KEYWORDS.any? { |k| k[0] =~ unindent(currently_line)  }
      keyword = BLOCK_KEYWORDS.each { |k| break k if k[0] =~ unindent(currently_line)  }
      currently_indent_depth = indent_count currently_line
      just_after_indent_depth = indent_count endless[i + 1]
      if currently_indent_depth < just_after_indent_depth || keyword[1..-1].any? { |k| k =~ unindent(endless[i + 1]) }
        base_indent_depth = currently_indent_depth
        inner_statements = []
        while i < endless.length
          break unless keyword[1..-1].any? { |k| k =~ unindent(endless[i + 1]) } || base_indent_depth < indent_count(endless[i + 1])
          inner_statements << endless[i + 1]
          i += 1
        end
        pure += endless_ruby_to_pure_ruby(inner_statements.join("\n")).split "\n"
      end
      pure += ["#{'  '*currently_indent_depth}end"]
      i += 1
    end
    pure.join "\n"
  end
  alias to_pure_ruby endless_ruby_to_pure_ruby
end
if __FILE__ == $PROGRAM_NAME
  outdir = File.expand_path "."
  srces = []
  until ARGV.empty?
    first = ARGV.shift
    case first
    when "-c", "--compile"
      until ARGV.empty?
        break if ARGV.first =~ /^\-.*$/
        srces << ARGV.shift
      end
    when "-o", "--output"
      outdir = File.expand_path ARGV.shift
    else
      $PROGRAM_NAME = first
      begin
        require("#{File.expand_path(first)}")
      rescue Exception => e
        $@ = $@[0..-7]
        raise e
      end
    end
  end
  until srces.empty?
    filename = srces.shift
    filename =~ /^(.*)\.er$/
    EndlessRuby.ercompile(File.expand_path(filename), "#{outdir}/#{File.split($1)[1]}.rb")
  end
end