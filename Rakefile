require 'bundler'
require 'rspec/core/rake_task'
require 'rdoc/task'
Bundler::GemHelper.install_tasks

task :default => :spec
RSpec::Core::RakeTask.new

RDoc::Task.new :rdoc do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Shortener'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
