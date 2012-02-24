#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "endlessruby"

module EndlessRuby::Main


    include EndlessRuby
    extend self

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
        require 'pathname'

        options = {
        }

        parser = OptionParser.new do |opts|
            opts.version = EndlessRuby::VERSION
            opts.on '-o OUT', 'appoint output directory.' do |out|
                options[:out] = out
            end
            opts.on '-c', '--compile', 'compile endlessruby source code to pure ruby' do |c|
                options[:compile] = c
            end
            opts.on '-d', '--decompile', 'decompile pure ruby source code to endless ruby' do |d|
                options[:decompile] = d
            end
            opts.on '-r', 'recursive compiling. (or decompiling when you specify the -d.)' do |r|
                options[:recursive] = r
            end
        end

        parser.parse! argv

        out = Pathname.new options[:out] || '.'

        if options[:decompile]
            callback = method :decompile
            in_ext = ".rb"
            out_ext = ".er"
        else
            callback = method :compile
            in_ext = ".er"
            out_ext = ".rb"
        end

        process = proc do |path|
            path = Pathname.new path
            unless path.exist?
                puts "no such file to load -- #{path}"
                next
            end
            if path.directory?
                puts "Is a directory - #{path}"
                next
            end
            if path.to_s =~ /^(.*)#{in_ext}$/
                o = Pathname.new "#{$1}#{out_ext}"
            else
                o = Pathname.new "#{path}#{out_ext}"
            end
            print "compiling '#{path}' to '#{out}/#{o.basename}'..."
            callback.call "#{path}", "#{out}/#{o.basename}"
            puts " done."
        end
        if options[:recursive]
            r = proc do |out_root, in_root, dir|
                Dir.entries((in_root + dir).to_s).each do |a_path|
                    out = out_root + dir
                    a_path = Pathname.new a_path
                    if a_path.extname == in_ext
                        process.call((in_root + dir + a_path).to_s)
                    end
                    if (in_root + a_path).directory? && a_path.to_s != "." && a_path.to_s != ".."
                        r.call out_root, in_root, dir + a_path
                    end
                end
            end
            argv.each do |dir|
                out_root = Pathname.new options[:out] || dir
                r.call out_root, Pathname.new(dir), Pathname.new(".")
            end
        elsif options[:compile] || options[:decompile]
            argv.each do |path|
                process.call path
            end
        end
    end
end