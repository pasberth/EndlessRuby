#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
module EndlessRuby::Main
  extend self
  extend EndlessRuby
  include EndlessRuby
  def compile er, rb
    open(er) do |erfile|
      open(rb, "w") do |rbfile|
        rbfile.write ER2PR(erfile.read)
      end
    end
  end
  def endlessruby *argv
    EndlessRuby::Main.main argv
  end
  def self.main *argv
    require 'optparse'
    options = {
    }
    parser = OptionParser.new do |opts|
      opts.on '-o OUT' do |out|
        options[:out] = out
      end
      opts.on '-c', '--compile' do |c|
        options[:compile] = true
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
      return
    end
    $PROGRAM_NAME = ARGV.shift
    open $PROGRAM_NAME do |file|
      EndlessRuby.ereval file.read, TOPLEVEL_BINDING, $PROGRAM_NAME
    end
  end
end