begin
  require 'rspec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  require 'rspec'
end
begin
  require 'rspec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
#  exit(0)
end

desc "Run the specs under spec/models"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  # t.spec_files = FileList['spec/*_spec.rb']
end
