ROOT = File.dirname(File.expand_path(__FILE__))
require "#{ROOT}/lib/endlessruby"

include EndlessRuby

`gcc src/endlessruby.c -o lib/endlessruby`
ercompile("#{ROOT}/src/endlessruby.er", "#{ROOT}/lib/endlessruby.rb")
