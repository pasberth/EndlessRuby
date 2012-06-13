# -*- coding: utf-8 -*-
ROOT = File.dirname(File.expand_path(__FILE__))

`endlessruby -c #{ROOT}/src/lib/endlessruby.er -o lib`
`endlessruby -c #{ROOT}/src/lib/endlessruby/custom_require.er #{ROOT}/src/lib/endlessruby/main.er -o lib/endlessruby`
`endlessruby -c #{ROOT}/src/bin/endlessruby.er -o bin`
`mv #{ROOT}/bin/endlessruby.rb #{ROOT}/bin/endlessruby`
`chmod 755 #{ROOT}/bin/endlessruby`

# アップデートでできるようにする予定
# $ endlessruby -rc src/lib -o lib
