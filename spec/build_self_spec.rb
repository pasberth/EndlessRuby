# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/spec_helper.rb'

bin = File.dirname(__FILE__) + "/../bin"
src = File.dirname(__FILE__) + "/../src"
lib = File.dirname(__FILE__) + "/../lib"

describe EndlessRuby, "must can compile self" do

  myself_sources = [
    "#{src}/endlessruby.er",
    "#{lib}/endlessruby.rb",
   "#{src}/endlessruby/main.er",
   "#{lib}/endlessruby/main.rb",
   "#{src}/endlessruby/extensions.er",
   "#{lib}/endlessruby/extensions.rb",
   "#{src}/er.er",
   "#{bin}/endlessruby",
  ]
  myself_sources.each_slice(2) do |er, rb|
    it "must can compile #{er} to #{rb}" do
      begin
        rb = open rb
        er = open er

        ER2RB(er.read).should == rb.read
      ensure
        rb.close
        er.close
      end
    end
  end

  myself_sources.each_slice(2) do |er, rb|
    it "must can decompile #{rb} to #{er}" do
      begin
        rb = open rb
        er = open er

        s = er.read
        # 改行は取り除く
        s = ERSpecHelper.chomp s

        RB2ER(rb.read).should == s
      ensure
        rb.close
        er.close
      end
    end
  end

end
