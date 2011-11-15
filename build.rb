ROOT = File.dirname(File.expand_path(__FILE__))
require "#{ROOT}/lib/endlessruby"

include EndlessRuby

ercompile("#{ROOT}/src/EndlessRuby.er", "#{ROOT}/lib/EndlessRuby.rb")
ercompile("#{ROOT}/src/EndlessRuby/extensions.er", "#{ROOT}/lib/EndlessRuby/extensions.rb")
