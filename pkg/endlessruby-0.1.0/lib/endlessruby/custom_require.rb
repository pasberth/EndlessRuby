#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'

module Kernel

  alias endlessruby_original_require require

  # EndlessRuby によって再定義された require です。
  # たいていのこのrequireはオリジナルなrequireまたはrubygemsのrequireがSyntaxErrorによって失敗した場合のみ機能します。
  # SytanxError によってrequireが失敗した場合、pathを探してpathまたはpath.erの名前のファイルをEndlessRubyの構文として評価します。
  # pathが./または/で以外で始まる場合は$LOAD_PATHと$:をそれぞれ参照してpathを探します。
  # もしpathがそれらで始まる場合はそれぞれ参照しません。(つまり通常のrequireの動作と同じです)
  def require path
    endlessruby_original_require path
  rescue SyntaxError, LoadError

    load = lambda do |path, abspath|

      if !File.exist?(abspath) || File.directory?(abspath)
        if File.exist? "#{abspath}.er"
          abspath = "#{abspath}.er"
        else
          raise LoadError, "no such file to load -- #{path}"
        end
      end

      return false if $".include? abspath

      if File.directory? abspath
        raise LoadError, "Is a directory - #{path}"
      end

      open(abspath) do |file|
        EndlessRuby.ereval file.read, TOPLEVEL_BINDING, abspath
        $" << abspath
        return true
      end
    end

    case path
    when /^\~(.*?)$/
      load.call path, File.join(ENV['HOME'], $1)
    when /^\.\/.*?$/, /^\/.*?$/
      load.call path, path
    else
      is_that_dir = false
      $:.each do |load_path|
        abspath = File.join load_path, path
        begin
          return load.call path, abspath
        rescue SyntaxError => e
          $stderr.puts "*ENDLESSRUBY BUG*"
          raise e
        rescue LoadError => e
          raise e if load_path == $:.last
        end
      end
    end
  end
end