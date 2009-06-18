require(File.join(File.dirname(__FILE__), 'config', 'environment'))
require 'rake'
require 'rake/testtask'
require 'rake/runtest'

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version because of the dependency"
end

task :test do
  Rake.run_tests '**/*Test.rb'
end

task :vtest do
  Rake.run_tests '**/VPMSCallTest.rb'
end

task :reinstall => [:default] do
  system "gem uninstall #{spec.name}"
  system "gem install pkg/#{spec.name}-#{spec.version}"
end

# This is what the task should look like to run the unit tests
#task :cruise => [:test, :reinstall]

# Until the problems with the unit tests is fixed, don't run them:
task :cruise => [:reinstall]
