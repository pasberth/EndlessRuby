ROOT = File.dirname(File.expand_path(__FILE__))

`endlessruby -c #{ROOT}/src/endlessruby.er -o lib`
`endlessruby -c #{ROOT}/src/endlessruby/extensions.er #{ROOT}/src/endlessruby/main.er -o lib/endlessruby`
`endlessruby -c #{ROOT}/src/er.er -o bin`
`mv #{ROOT}/bin/er.rb #{ROOT}/bin/endlessruby`
`chmod 755 #{ROOT}/bin/endlessruby`
