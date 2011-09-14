ROOT = File.dirname(File.expand_path(__FILE__))
require "#{ROOT}/lib/endlessruby"

include EndlessRuby

ercompile("#{ROOT}/src/endlessruby.er", "#{ROOT}/lib/endlessruby.rb")
