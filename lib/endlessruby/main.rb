#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module EndlessRuby::Main

  extend self
  extend EndlessRuby
  include EndlessRuby

  # er ファイルから読み込みそれをピュアなRubyにコンパイルしてrbに書き出します
  def compile er, rb
    ER2PR({ :in => { :any => er }, :out => { :any => rb } })
  end

  # rbファイルを読み込みそれからすべてのendを取り除きます。
  def decompile rb, er
    PR2ER({ :in => { :any => rb }, :out => { :any => er } })
  end

  # EndlessRuby::Main.main と同じ動作をします。このモジュールをincludeした場合に使用します。
  def endlessruby argv
    EndlessRuby::Main.main argv
  end

  # $ endlessruby.rb args とまったく同じ動作をします。argvはARGVと同じ形式でなければなりません。
  def self.main argv

    if argv.first && File.exist?(argv.first)
      $PROGRAM_NAME = argv.shift
      open $PROGRAM_NAME do |file|
        EndlessRuby.ereval file.read, TOPLEVEL_BINDING, $PROGRAM_NAME
      end
      return true
    end

    require 'optparse'

    options = {
    }

    parser = OptionParser.new do |opts|

      opts.version = EndlessRuby::VERSION

      opts.on '-o OUT', 'appoint output directory.' do |out|
        options[:out] = out
      end

      opts.on '-c', '--compile', 'compile endlessruby source code to pure ruby' do |c|
        options[:compile] = true
      end

      opts.on '-d', '--decompile', 'decompile pure ruby source code to endless ruby' do |d|
        options[:decompile] = true
      end

      opts.on '-r' do |r|
        options[:recursive] = true
      end
    end

    parser.parse! argv

    if options[:compile]
      out = options[:out] || '.'

      argv.each do |er|
        unless File.exist? er
          puts "no such file to load -- #{er}"
          next
        end

        if File.directory? er
          unless options[:recursive]
            puts "Is a directory - #{er}"
            next
          end
          # Unimolementation
          next
        end

        rb = er
        if er =~ /^(.*)\.er$/
          rb = $1
        end
        rb = File.split(rb)[1]
        rb = File.join(out, "#{rb}.rb")
        compile er, rb
      end
    elsif options[:decompile]
      out = options[:out] || '.'

      argv.each do |rb|
        unless File.exist? rb
          puts "no such file to load -- #{rb}"
          next
        end

        if File.directory? rb
          unless options[:recursive]
            puts "Is a directory - #{rb}"
            next
          end
          # Unimolementation
          next
        end

        er = rb
        if rb =~ /^(.*)\.rb$/
          er = $1
        end
        er = File.split(er)[1]
        er = File.join(out, "#{er}.er")
        decompile rb, er
      end
    end
  end
end