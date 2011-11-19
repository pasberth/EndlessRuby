begin
  require 'rspec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  require 'rspec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'endlessruby'

$:.unshift(File.dirname(__FILE__))

include EndlessRuby

module ERSpecHelper

  extend self

  def indent lines, level=1, indent=' '
    lines.split("\n").map! { |l| "#{indent*level}#{l}" }.join "\n"
  end

  def join_blocks blocks, insert_end=false, level=0, indent='  '
    blocks.each_slice(2).map do |b, i|
      [].tap do |a|
        a << indent(b, level, indent)
        a << join_blocks(i, insert_end, level+1, indent) unless i.nil? || i.empty?
        a << indent('end', level, indent) if insert_end
      end.join "\n"
    end.join "\n"
  end

end
