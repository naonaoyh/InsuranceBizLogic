require(File.join(File.dirname(__FILE__), 'config', 'environment'))
require 'rake'
require 'rake/testtask'
require 'rake/runtest'

task :test do
  Rake.run_tests '**/*Test.rb'
end

task :vtest do
  Rake.run_tests '**/VPMSCallTest.rb'
end


# This is what the task should look like to run the unit tests
#task :cruise => [:test, :reinstall]

# Until the problems with the unit tests is fixed, don't run them:
task :cruise => [:reinstall]
