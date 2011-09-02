ROOT = File.dirname(File.expand_path(__FILE__))
require "#{ROOT}/lib/endlessruby"

include EndlessRuby

open("#{ROOT}/src/endlessruby.er") do |er|
  open("#{ROOT}/lib/endlessruby.rb", "w") do |out|
    out.write endless_ruby_to_pure_ruby(er.read)
  end
end 
