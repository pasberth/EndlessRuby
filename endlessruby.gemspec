Gem::Specification.new do |s|
  s.name = "endlessruby"
  s.version = File.read("VERSION")
  s.authors = ["pasberth"]
  s.description = %{You can write source code without the use of 'end'.}
  s.summary = %q{}
  s.email = "pasberth@gmail.com"
  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.homepage = "http://github.com/pasberth/endlessruby"
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
