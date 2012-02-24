# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/spec_helper.rb'

bin = File.dirname(__FILE__) + "/../bin"
src = File.dirname(__FILE__) + "/../src"
lib = File.dirname(__FILE__) + "/../lib"

describe EndlessRuby, "must can compile self" do

  myself_sources = [
    "#{src}/lib/endlessruby.er",
    "#{lib}/endlessruby.rb",
   "#{src}/lib/endlessruby/main.er",
   "#{lib}/endlessruby/main.rb",
   "#{src}/lib/endlessruby/custom_require.er",
   "#{lib}/endlessruby/custom_require.rb",
   "#{src}/bin/endlessruby.er",
   "#{bin}/endlessruby",
  ]
  myself_sources.each_slice(2) do |er, rb|
    it "must can compile #{er} to #{rb}" do
      begin
        rb_f = open rb
        er_f = open er

        ER2RB(er_f.read).should == rb_f.read
      ensure
        rb_f.close if defined? rb_f
        er_f.close if defined? er_f
      end
    end
  end

  myself_sources.each_slice(2) do |er, rb|
    it "must can decompile #{rb} to #{er}" do
      begin
        rb_f = open rb
        er_f = open er

        s = er_f.read

        RB2ER(rb_f.read).should == s
      ensure
        rb_f.close if defined? rb_f
        er_f.close if defined? er_f
      end
    end
  end

end
