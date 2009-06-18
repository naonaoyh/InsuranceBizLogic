# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'test/unit'
require File.join(File.dirname(__FILE__),'..','..','lib','bizLogic','diff')
require 'Tempfile'

APP_CONFIG = YAML.load_file('config/environment.yml')

class DiffTest < Test::Unit::TestCase
  include XMLDiff
  def test_diff
    result = determineDiff('<value>1</value>', '<value>2</value>');
    puts "[#{result}]"
  end
end
